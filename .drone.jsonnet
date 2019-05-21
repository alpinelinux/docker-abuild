local tags = ['v3.6', 'v3.7', 'v3.8', 'v3.9', 'edge'];
local tags_armv7 = ['v3.9', 'edge'];

local pipeline(arch, darch, tags) = {
  kind: 'pipeline',
  name: arch,
  platform: {
    os: 'linux',
    arch: darch,
  },
  steps: [
    {
      name: 'dockerfiles',
      image: 'alpine',
      commands: ['./dockerfiles.sh'],
    },
  ] + [
    {
      name: tag,
      image: 'plugins/docker',
      settings: {
        username: {
          from_secret: 'docker_user',
        },
        password: {
          from_secret: 'docker_pass',
        },
        repo: 'alpinelinux/docker-abuild',
        tags: '%s-%s' % [std.strReplace(tag, 'v', ''), arch],
        dockerfile: 'Dockerfiles/%s/%s/Dockerfile' % [tag, arch],
      },
      depends_on: ['dockerfiles'],
    }
    for tag in tags
  ],
};

[
  pipeline('x86', 'amd64', tags),
  pipeline('x86_64', 'amd64', tags),
  pipeline('aarch64', 'arm64', tags),
  pipeline('armhf', 'arm', tags),
  pipeline('armv7', 'arm', tags_armv7),
]
