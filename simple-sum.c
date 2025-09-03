#include <assert.h>
#include <errno.h>
#include <stdint.h>
#include <stdio.h>
#include <unistd.h>
#include <fcntl.h>

/* This code was written by DeepSeek. */

int
main(int argc, char* argv[])
{
    int rv = setvbuf(stdout, 0, _IONBF, 0);
    assert(rv == 0);

    if (argc < 2) {
        fprintf(stderr, "Usage: %s <file1>\n", argv[0]);
        return 1;
    }

    // Open the file using open(2)
    int fd = open(argv[1], O_RDONLY);
    if (fd == -1) {
        perror("open failed");
        return 1;
    }

    uint64_t sum = 0;
    uint32_t num;
    ssize_t bytes_read;

    // Read 32-bit unsigned integers from the file until EOF
    while ((bytes_read = read(fd, &num, sizeof(uint32_t))) > 0) {
        if (bytes_read != sizeof(uint32_t)) {
            fprintf(stderr, "Error: incomplete read (expected %zu bytes, got %zd)\n", 
                    sizeof(uint32_t), bytes_read);
            close(fd);
            return 1;
        }
        
        sum += num;
        printf("Partial sum: %lu\n", sum);
    }

    if (bytes_read == -1) {
        perror("Error reading from file");
        close(fd);
        return 1;
    }

    close(fd);
    printf("Final sum: %lu\n", sum);
    return 0;
}
