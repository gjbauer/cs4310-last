#include <assert.h>
#include <errno.h>
#include <stdint.h>
#include <stdio.h>

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

    uint64_t sum = 0;

    while (0 /* read until EOF */) {
        printf("Partial sum: %lu\n", sum);
    }

    printf("Final sum: %lu\n", sum);
    return 0;
}
