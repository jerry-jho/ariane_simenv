import yaml
import sys
import argparse

parser = argparse.ArgumentParser(description='yaml filelist processing')
parser.add_argument('-f','--file',type=str,help='imput filename')
parser.add_argument('-k','--keys',type=str,help='collection keys')
parser.add_argument('-s','--stype',type=str,nargs='?',default='vcs',help='output style, vcs for default')

args = parser.parse_args()

ymlfile = args.file
keylist = args.keys

x = yaml.load(open(ymlfile))


for k in keylist.split(','):
    v = x[k]
    root = v.get('root','.')
    for i in v.get('options',[]):
        print("%s" % i)
    for i in v.get('defines',[]):
        print("+define+%s" % i)
    for i in v.get('libdirs',[]):
        print("-y %s/%s" % (root,i))            

    for i in v.get('incdirs',[]):
        if i[0] == '$' or i[0] == '/':
            print("+incdir+%s" % i)
        else:
            print("+incdir+%s/%s" % (root,i))
            

    for i in v.get('files',[]):
        if i[0] == '$' or i[0] == '/':
            print(i)
        else:
            print("%s/%s" % (root,i))    
    
#print(ymlfile,keylist,root)