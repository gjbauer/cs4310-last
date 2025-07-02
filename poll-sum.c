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
        fprintf(stderr, "Usage: %s <file1> [file2] ...\n", argv[0]);
        return 1;
    }

    // Open the files

    uint64_t total_sum = 0;

    while (0 /* at least one file still open */) {
        // fprintf(stderr, "Waiting on poll.\n");

        // poll

        // Check each file descriptor for events,
        // read and add to sum or close.
        printf("Partial sum: %lu\n", total_sum);
    }

    printf("Final sum: %lu\n", total_sum);
    return 0;
}
