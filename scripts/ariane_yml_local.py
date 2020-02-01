import yaml
import sys
import os

_,ymlfile,keylist,dst = sys.argv

x = yaml.load(open(ymlfile))

dst_dirs = {}
dst_cmds = []

for k in keylist.split(','):
    v = x[k]
    root = v.get('root','.')
    if 'files' in v.keys():
        for i in v['files']:
            if i[0] == '$' or i[0] == '/':
                continue
            dst_path = os.path.dirname(i) + '/'
            dst_dirs[dst_path] = 1
            dst_cmds.append('cp %s/%s %s/%s' % (root,i,dst,dst_path))
            
for k in dst_dirs.keys():
    print('mkdir -p %s/%s' % (dst,k))
    
for k in dst_cmds:
    print(k)
            
    
#print(ymlfile,keylist,root)