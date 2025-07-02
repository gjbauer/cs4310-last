#include <assert.h>
#include <errno.h>
#include <stdint.h>
#include <stdio.h>
#include <sys/stat.h>
#include <sys/mman.h>
#include <fcntl.h>
#include <stdbool.h>

int
main(int argc, char* argv[])
{
    int rv = setvbuf(stdout, 0, _IONBF, 0);
    assert(rv == 0);

    if (argc < 2) {
        fprintf(stderr, "Usage: %s <file1>\n", argv[0]);
        return 1;
    }

    // Open
    
    int fd = open(argv[1], O_RDWR);
    
    struct stat fs;
    
    uint64_t sum = 0;
    
    int pos = 0;
    
    stat(argv[1], &fs);
        uint64_t *mmap_base = (uint64_t*)mmap(0, fs.st_size, PROT_READ | PROT_WRITE, MAP_SHARED, fd, 0);
        
        while (true) {
        	if (pos == fs.st_size) break;
        	sum += *mmap_base;
        	*mmap_base++, pos++;
        	printf("Partial sum: %lu\n", sum);
    	}

    printf("Final sum: %lu\n", sum);
    return 0;
}
