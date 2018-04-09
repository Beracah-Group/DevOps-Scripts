#!/usr/bin/env python
import json
import subprocess, os
from urllib.request import urlopen

config = json.load(open('config.json'))

scriptURL = config['base']['scriptURL']

scripts = []


class Script(object):
    def __repr__(self):
        return 'Script: {}'.format(self.name)

    def __init__(self, name, env_vars):
        self.name = name

        self.env_vars = env_vars

    @property
    def script(self):
        return self.name.split('/')[-1]

    def execute(self):
        run_file = "/var/lib/waagent/custom-script/provisioning-{}.lock".format(self.script)

        if not os.path.exists(run_file):
            print("Executing {}".format(self))

            env = {**os.environ.copy(), **self.env_vars}
            result = subprocess.run('./{}'.format(self.script), shell=True, env=env)

            result.check_returncode()

            # Create run file to indicate that the script has been ran.
            open(run_file, 'a').close()
        else:
            print("{} has already been ran. Skipping execution.".format(self.script))

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


for key in config:
    if 'scripts' in config[key]:
        for script in config[key]['scripts']:
            scripts.append(Script(name=script, env_vars=config[key]['envVars'] if 'envVars' in config[key] else {}))

scripts = sorted(scripts, key=lambda x: x.script)

for script in scripts:
    print("------------------{}------------------".format(script))
    script.pull()
    script.execute()
    print("-------------------------------------------------------")
