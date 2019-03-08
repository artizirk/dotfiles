#!/usr/bin/python3
# source https://gitlab.com/snippets/1832968

import json
from subprocess import Popen, PIPE, run


def get_tree():
    proc = run(['swaymsg', '-t', 'get_tree'], capture_output=True)
    return json.loads(proc.stdout)


def traverse(data, out):
    if 'nodes' not in data:
        return

    if data['type'] == 'con' and 'window_properties' in data:
        props = data['window_properties']
        out.append((f'{props["class"]}: {props["title"]}'))

    for node in data['nodes']:
        if 'nodes' in node:
            traverse(node, out)


def main():
    apps = []
    traverse(get_tree(), apps)
    in_data = '\n'.join(apps).encode()

    with Popen(['fzf'], stdout=PIPE, stdin=PIPE) as proc:
        stdout, _ = proc.communicate(in_data)
        app = stdout.decode().split(':')[1].strip()

    run(['swaymsg', f'[title="{app}"] focus'])


if __name__ == '__main__':
    main()
