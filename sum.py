sum = 0
for i, line in enumerate(open('temp1.txt')):
	if "SUM" in line:
		sum = sum + float(line.split()[5])
	else:
		sum = sum + float(line.split()[6])

print (sum * 8 / 1000)
