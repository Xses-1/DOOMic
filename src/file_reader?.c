#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#define MAX_ROWS 100
#define MAX_COLS 2

int main() {
    FILE *file;
    char line[2048];
    int data[MAX_ROWS][MAX_COLS];
    int row = 0, col, value;
    char token[20];
	int pointer;
	int pointer2;

    // Open the file
    file = fopen("../verticies.csv", "r");
    if (file == NULL) {
        perror("Error opening file");
        return 1;
    }

    // Read each line from the file
    while (fgets(line, sizeof(line), file)) {
        col = 0;

        // Check if the line contains a single number
        if (strlen(line) <= 5) {
			sscanf(line, "%d", &value); 

            // It's a new set, reset the column index and increment the row index
            data[row++][col] = value;
			data[row - 1][1] = 666;

        } else {
            // Tokenize the line using ';' as the delimiter
			for (pointer = 0; line[pointer] != ';'; pointer++){}
			strncpy(token, line, pointer); 
			data[row][col++] = atoi(token);

			printf("The first: %s %d %d %d \n", token, atoi(token), pointer, pointer2);

			for (pointer2 = pointer + 1; line[pointer2] != ';'; pointer2++){}
			strncpy(token, line + pointer + 1, pointer2 - pointer);
			data[row][col++] = atoi(token);

			printf("The shit: %s %d %d %d \n", token, atoi(token), pointer, pointer2);
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

