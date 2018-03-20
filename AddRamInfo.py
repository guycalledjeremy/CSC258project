# file-input.py
get_bin = lambda x: format(x, 'b')
# f = open('EvilSnowman.txt','r')
with open('EvilSnowman.txt') as f:
    mylist = f.read().splitlines()
wf = open('EvilSnowmanTest.txt', 'w')
x_val = 0
y_val = 0
end = 1
for line in mylist:
    if x_val == 19 and y_val == 39:
        end = 0
    x_str = get_bin(x_val)
    y_str = get_bin(y_val)
    while len(x_str) < 6:
        x_str = "0" + x_str
    while len(y_str) < 6:
        y_str = "0" + y_str
    newstr = x_str + y_str + line + str(end) + "\n"
    wf.write(newstr)
    if x_val != 19:
        x_val += 1
    elif x_val == 19:
        x_val = 0
        y_val += 1
f.close()
wf.close()
