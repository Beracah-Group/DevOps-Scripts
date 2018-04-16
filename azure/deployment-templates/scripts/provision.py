#!/usr/bin/env python
import json
import subprocess, os
from collections import OrderedDict
from urllib.request import urlopen
import hashlib


class Script(object):
    RUN_LOCK_PATH = "/var/lib/waagent/custom-script/"

    def __repr__(self):
        return 'Script: {}'.format(self.name)

    def __init__(self, name, env_vars, flags=''):
        self.name = name

        self.env_vars = OrderedDict(sorted(env_vars.items(), key=lambda t: t[0]))

        self.flags = flags

    @property
    def script(self):
        return self.name.split('/')[-1]

    def execute(self):
        run_file = "{}provisioning-{}.lock".format(Script.RUN_LOCK_PATH, self.script)

        # Get the hash from the lock file
        if os.path.exists(run_file):
            lock_hash = str(open(run_file, 'r').read())
        else:
            print("First run")
            lock_hash = "first"

        # Hash the script file content and the config
        script_hash = hashlib.sha256()
        script_hash.update(str(open(self.script, 'r').read()).encode())
        script_hash.update(str(self.env_vars).encode())
        script_hash = script_hash.hexdigest()

        do_exec = False

        # Execute script if the hashes do not match
        if lock_hash != script_hash:
            if lock_hash == "first":
                do_exec = True

            if 'i' in self.flags.lower():
                do_exec = True
            else:
                print("{} would run again however script is not marked idempotent".format(self.script))
        else:
            if 'a' in self.flags.lower():
                do_exec = True
                print("{} marked execute always.".format(self.script))
            else:
                print("{} has already been ran. Skipping execution.".format(self.script))

        if do_exec:
            print("Executing {}".format(self))

            env = {**os.environ.copy(), **self.env_vars}
            result = subprocess.run('./{}'.format(self.script), shell=True, env=env)

            result.check_returncode()

            # Create run file to indicate that the script has been ran.
            with open(run_file, 'w') as f:
                f.write(script_hash)

    def pull(self):
        if not os.path.exists(self.script):
            print("Pulling {} from {}".format(self.name, scriptURL))

            resource = urlopen('{}/{}'.format(scriptURL, self.name), timeout=30)
            content = resource.read().decode(resource.headers.get_content_charset())

            with open(self.script, 'w') as f:
                f.write(content)
                os.chmod(self.script, 744)
        else:
            print("{} already exists. Not pulling.".format(self.script))


if "DEBUG" in os.environ.keys():
    Script.RUN_LOCK_PATH = ""

    script = Script('test.sh', {"blah": "thiasfdasdfnsg"}, False)
    script.pull()
    script.execute()
else:
    config = json.load(open('config.json'))

    scriptURL = config['base']['scriptURL']

    scripts = []
    for key in config:
        if 'scripts' in config[key]:
            for script in config[key]['scripts']:
                scripts.append(
                    Script(
                        name=script,
                        env_vars=config[key]['envVars'] if 'envVars' in config[key] else {},
                        flags=config[key]['scripts'][script]
                    )
                )

    scripts = sorted(scripts, key=lambda x: x.script)

    for script in scripts:
        print("------------------{}------------------".format(script))
        script.pull()
        script.execute()
        print("-------------------------------------------------------")
