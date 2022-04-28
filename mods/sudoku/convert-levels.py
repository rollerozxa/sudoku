import glob
import natsort

levelfiles = []

filelist = glob.glob('*.txt')
for infile in natsort.natsorted(filelist):
	print(infile)
	levelfiles.append(str(infile))

with open("levels.lua", "w") as f:
	f.write("levels = {\n\t{},\n\t{},\n\t{},\n\t{}\n}\n\n")

	for lvl in levelfiles:
		with open(lvl, "r") as f2:
			lvldata = f2.read()
			f.write("levels[%s] = [[\n%s]]\n\n" % (lvl.replace('.txt', '').replace('lv', '').replace('_', ']['), lvldata) )