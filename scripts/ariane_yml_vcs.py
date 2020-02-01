import yaml
import sys

_,ymlfile,keylist = sys.argv

x = yaml.load(open(ymlfile))


for k in keylist.split(','):
    v = x[k]
    root = v.get('root','.')
    if 'options' in v.keys():
        for i in v['options']:
            print("%s" % i)     
    if 'defines' in v.keys():
        for i in v['defines']:
            print("+define+%s" % i) 
    if 'libdirs' in v.keys():
        for i in v['libdirs']:
            print("-y %s/%s" % (root,i))            
    if 'incdirs' in v.keys():
        for i in v['incdirs']:
            if i[0] == '$' or i[0] == '/':
                print("+incdir+%s" % i)
            else:
                print("+incdir+%s/%s" % (root,i))
    if 'files' in v.keys():
        for i in v['files']:
            if i[0] == '$' or i[0] == '/':
                print(i)
            else:
                print("%s/%s" % (root,i))    
    
#print(ymlfile,keylist,root)