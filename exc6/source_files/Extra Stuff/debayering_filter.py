import numpy as np

def debayer_image_from_text(input_path, output_path, width, height):
    # Read pixel values from the text file
    with open(input_path, 'r') as file:
        pixel_values = [int(line.strip()) for line in file]
 
    # Perform GBRG debayering manually
    # Ensure the number of pixels matches the expected size
    if len(pixel_values) != width * height:
        print("Error: The number of pixel values does not match the specified dimensions.")
        return

    # Reshape the pixel values into a 2D array
    tmp_bayer_image = np.array(pixel_values, dtype=np.uint16).reshape((height, width))
    bayer_image = np.zeros((height+2, width+2), dtype=np.uint16)
    bayer_image[1:height+1,1:width+1] = tmp_bayer_image

    # for i in range(0, height+2):
    #     for j in range(0, width+2):
    #         print(bayer_image[i, j], end=' ')
    #     print("\n")

    # Initialize an empty array for the RGB image
    color_image = np.zeros((height, width, 3), dtype=np.uint16)

    # Perform manual GBRG debayering
    for i in range(1, height+1):
        for j in range(1, width+1):
            if (i+1) % 2 == 0 and (j+1) % 2 == 0:  # Green pixel (even row, even column)
                color_image[i-1,j-1, 1] = bayer_image[i, j]
                color_image[i-1,j-1, 0] = (bayer_image[i - 1, j] + bayer_image[i + 1, j]) // 2
                color_image[i-1,j-1, 2] = (bayer_image[i, j - 1] + bayer_image[i, j + 1]) // 2
            elif (i+1) % 2 == 0 and (j+1) % 2 == 1:  # Blue pixel (even row, odd column)
                color_image[i-1,j-1, 2] = bayer_image[i, j]
                color_image[i-1,j-1, 1] = (bayer_image[i - 1, j] + bayer_image[i + 1, j] +
                                        bayer_image[i, j - 1] + bayer_image[i, j + 1]) // 4
                color_image[i-1,j-1, 0] = (bayer_image[i - 1, j - 1] + bayer_image[i - 1, j + 1] +
                                        bayer_image[i + 1, j - 1] + bayer_image[i + 1, j + 1]) // 4
            elif (i+1) % 2 == 1 and (j+1) % 2 == 0:  # Red pixel (odd row, even column)
                color_image[i-1,j-1, 0] = bayer_image[i, j]
                color_image[i-1,j-1, 1] = (bayer_image[i - 1, j] + bayer_image[i + 1, j] +
                                        bayer_image[i, j - 1] + bayer_image[i, j + 1]) // 4
                color_image[i-1,j-1, 2] = (bayer_image[i - 1, j - 1] + bayer_image[i - 1, j + 1] +
                                        bayer_image[i + 1, j - 1] + bayer_image[i + 1, j + 1]) // 4
            else:  # Green pixel (odd row, odd column)
                color_image[i-1,j-1, 1] = bayer_image[i, j]
                color_image[i-1,j-1, 0] = (bayer_image[i, j - 1] + bayer_image[i, j + 1]) // 2
                color_image[i-1,j-1, 2] = (bayer_image[i - 1, j] + bayer_image[i + 1, j]) // 2

    # Write the resulting RGB values to a text file
    
    with open(output_path, 'w+') as file:
        for row in color_image:
            for pixel in row:
                file.write(f"{tuple(pixel)}\n")
    print(f"Debayered RGB values saved to {output_path}")


if __name__ == "__main__":
    # Example usage
    input_file = "input_1024.txt"  # Replace with your input text file containing pixel values
    output_file = "output_1024.txt"  # Replace with your desired output file name
    image_size = 1024  # Replace with 32, 64, or 128 based on your Bayer image dimensions
    debayer_image_from_text(input_file, output_file, image_size, image_size)
