from sys import *

def maxbord(string,L):
   max = 0
   for r in range(1,L):
      # test for border of size r
      # testing if string[0..r-1] == string[L-r..L-1]
      isborder = 1
      for i in range(r):
         if string[i] == string[L-r+i]:
            continue
         else:
           isborder = 0
           break
      #end for
      if isborder == 1:
         if max < r:
            max = r
   #end for
   return max
#end maxbord

def simple_display(bordar,L):
   print("border array:",end='')
   print(bordar[0],end='')
   for i in range(1,L): 
      print(",",bordar[i],end='')
   #end for
   print("")
#end simple_display


def display_line(bordar,level,L):
   count = 0
   for x in bordar:
      count += 1
      if count > L: break
      if level == 1:
         if x > 0:
            print("+++  ",end='')
         else:
            print("...  ",end='')
      else:
         if x < level:
            print("     ",end='')
         else:
            print("+++  ",end='')
   #end for
   print("")
#end display_line


def fancy_display(bordar,L):
   for level in range(L,0,-1):
      display_line(bordar,level,L)
   #end for
#end fancy_display
   

def main():
   if len(argv) != 2:
      print("incorrect number of command line argumemts")
      exit(0)
   string = argv[1]
   L = len(string)
   if L > 12:
      print("imput string too long")
      return
   else:
      print("imput string: ",end='')
      print(string)
   bordar=[0,0,0,0,0,0,0,0,0,0,0,0] # "empty" array of size 12
   L1=L
   for i in range(L-1):
      bordar[i] = maxbord(string[i:],L1)
      L1 = L1-1
   #end for
   simple_display(bordar,L)
   fancy_display(bordar,L)
#end main

main()
