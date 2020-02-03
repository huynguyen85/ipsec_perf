sum = 0
for i, line in enumerate(open('temp1.txt')):
	if "SUM" in line:
		sum = sum + float(line.split()[5])

print (sum * 8 / 1000)
