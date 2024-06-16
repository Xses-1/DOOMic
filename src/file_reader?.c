#include <stdio.h>
#include <stdlib.h>

#define MAX_ROWS 100
#define MAX_COLS 3

int main() {
    FILE *file;
    char line[1024];
    int data[MAX_ROWS][MAX_COLS];
    int row = 0, col, value;
    char *token;

    // Open the file
    file = fopen("data.txt", "r");
    if (file == NULL) {
        perror("Error opening file");
        return 1;
    }

    // Read each line from the file
    while (fgets(line, sizeof(line), file)) {
        col = 0;

        // Check if the line contains a single number
        if (sscanf(line, "%d", &value) == 1 && value < 100) {
            // It's a new set, reset the column index and increment the row index
            data[row++][col] = value;
        } else {
            // Tokenize the line using ';' as the delimiter
            token = strtok(line, ";");
            while (token != NULL && col < MAX_COLS) {
                // Convert token to integer and store it in the array
                data[row][col++] = atoi(token);
                token = strtok(NULL, ";");
            }
            row++;
        }
    }

    // Close the file
    fclose(file);

    // Print the 2D array
    for (int i = 0; i < row; i++) {
        for (int j = 0; j < MAX_COLS; j++) {
            printf("%d ", data[i][j]);
        }
        printf("\n");
    }

    return 0;
}

