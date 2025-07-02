all: simple-sum poll-sum

simple-sum: simple-sum.c
	gcc -g -o simple-sum simple-sum.c

poll-sum: poll-sum.c
	gcc -g -o poll-sum poll-sum.c

clean:
	rm -f simple-sum poll-sum
