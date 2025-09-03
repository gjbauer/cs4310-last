#include <assert.h>
#include <errno.h>
#include <stdint.h>
#include <stdio.h>
#include <unistd.h>
#include <fcntl.h>
#include <poll.h>
#include <stdlib.h>

/* This code was written by DeepSeek. */

int
main(int argc, char* argv[])
{
    int rv = setvbuf(stdout, 0, _IONBF, 0);
    assert(rv == 0);

    if (argc < 2) {
        fprintf(stderr, "Usage: %s <file1> [file2] ...\n", argv[0]);
        return 1;
    }

    int num_files = argc - 1;
    struct pollfd *fds = malloc(num_files * sizeof(struct pollfd));
    if (fds == NULL) {
        perror("malloc failed");
        return 1;
    }

    // Open all files
    for (int i = 0; i < num_files; i++) {
        fds[i].fd = open(argv[i + 1], O_RDONLY | O_NONBLOCK);
        if (fds[i].fd == -1) {
            perror("open failed");
            // Clean up already opened files
            for (int j = 0; j < i; j++) {
                close(fds[j].fd);
            }
            free(fds);
            return 1;
        }
        fds[i].events = POLLIN;
        fds[i].revents = 0;
    }

    uint64_t total_sum = 0;
    int open_files = num_files;

    while (open_files > 0) {
        // Wait for events on any file descriptor
        int ready = poll(fds, num_files, -1);
        if (ready == -1) {
            perror("poll failed");
            break;
        }

        // Check each file descriptor for events
        for (int i = 0; i < num_files; i++) {
            if (fds[i].fd == -1) continue; // Skip closed files

            if (fds[i].revents & POLLIN) {
                // File is ready for reading
                uint32_t num;
                ssize_t bytes_read = read(fds[i].fd, &num, sizeof(uint32_t));
                
                if (bytes_read == sizeof(uint32_t)) {
                    total_sum += num;
                    printf("Partial sum: %lu\n", total_sum);
                } else if (bytes_read == 0) {
                    // EOF reached
                    close(fds[i].fd);
                    fds[i].fd = -1;
                    open_files--;
                } else if (bytes_read == -1) {
                    if (errno != EAGAIN && errno != EWOULDBLOCK) {
                        perror("read error");
                        close(fds[i].fd);
                        fds[i].fd = -1;
                        open_files--;
                    }
                }
            } else if (fds[i].revents & (POLLHUP | POLLERR)) {
                // File has been closed or error occurred
                close(fds[i].fd);
                fds[i].fd = -1;
                open_files--;
            }
            
            // Clear revents for next poll call
            fds[i].revents = 0;
        }
    }

    // Clean up
    for (int i = 0; i < num_files; i++) {
        if (fds[i].fd != -1) {
            close(fds[i].fd);
        }
    }
    free(fds);

    printf("Final sum: %lu\n", total_sum);
    return 0;
}
