# 4x4 Matrix Multiplication in Python

# Define two 4x4 matrices
A = [
    [1, 2, 3, 4],
    [5, 6, 7, 8],
    [9, 10, 11, 12],
    [13, 14, 15, 16]
]

B = [
    [1, 2, 3, 4],
    [5, 6, 7, 8],
    [9, 10, 11, 12],
    [13, 14, 15, 16]
]

# Initialize result matrix with zeros
C = [[0 for _ in range(4)] for _ in range(4)]

# Matrix multiplication
for i in range(4):
    for j in range(4):
        for k in range(4):
            C[i][j] += A[i][k] * B[k][j]

print("Matrix A:")
for row in A:
    print(row)

print("Matrix B:")
for row in B:
    print(row)

# Print result
print("Result matrix C:")
for row in C:
    print(row)
