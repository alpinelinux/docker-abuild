#!/usr/bin/python

import urllib.request, json, os, shutil
from jinja2 import Template

releases = "https://alpinelinux.org/releases.json"
template = "child.tpl.yml"
pipeline = "out/child.yml"

with urllib.request.urlopen(releases) as url:
    data = json.load(url)
    
with open(template) as f:
    os.makedirs('out', exist_ok=True)
    Template(f.read(), trim_blocks=True, lstrip_blocks=True).stream(
            data=data['release_branches'][0:5]).dump(pipeline)
    f.close()

for branch in data['release_branches'][0:5]:
    tag = branch['rel_branch'].lstrip('v')
    release = branch['rel_branch']
    directory = ('out/{}').format(release)
    outfile = os.path.join(directory, 'Dockerfile')
    os.makedirs(directory, exist_ok=True)
    with open('Dockerfile.in') as f:
        Template(f.read(), trim_blocks=True, lstrip_blocks=True).stream(
                tag=tag, release=release).dump(outfile)
        f.close()
    shutil.copyfile('entrypoint.sh', ('out/{}/entrypoint.sh').format(release))
    shutil.copymode('entrypoint.sh', ('out/{}/entrypoint.sh').format(release))
