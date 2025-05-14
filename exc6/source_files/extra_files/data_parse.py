# Open the input file and read the numbers
with open("input_1024.txt", "r") as infile:
    numbers = [int(line.strip()) for line in infile]

# Generate the C header file content
header_content = "#ifndef DATA_ARRAY_H\n#define DATA_ARRAY_H\n\n"
header_content += f"uint8_t data_array[1048576] = {{\n    {', '.join(map(str, numbers))}\n}};\n\n"
header_content += "#endif // DATA_ARRAY_H\n"

# Write the content to a header file
with open("data_array_1024.h", "w+") as outfile:
    outfile.write(header_content)