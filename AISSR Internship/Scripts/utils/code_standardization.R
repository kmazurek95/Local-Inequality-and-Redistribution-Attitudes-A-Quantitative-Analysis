# Utility Functions for Geographic Code Standardization
# ====================================================

# Function to add leading zeros to Buurtcodes
# This function ensures all Buurtcodes are standardized to 8 digits.
# If the input code has fewer than 8 digits, leading zeros are added.
# If the input code is already 8 digits, it remains unchanged.
# Invalid codes (not between 5 and 8 digits) return NA.
standardize_buurtcode <- function(code) {
  # Convert the code to a character string (in case it's numeric)
  code <- as.character(code)
  
  # Check the length of the code and add leading zeros accordingly
  if (nchar(code) == 5) {
    return(paste0("000", code)) # Add 3 leading zeros to make it 8 digits
  } else if (nchar(code) == 6) {
    return(paste0("00", code))  # Add 2 leading zeros to make it 8 digits
  } else if (nchar(code) == 7) {
    return(paste0("0", code))   # Add 1 leading zero to make it 8 digits
  } else if (nchar(code) == 8) {
    return(code)                # Already valid; return as is
  } else {
    return(NA)                  # Invalid code length; return NA
  }
}

# Function to generate Wijkcode (6 digits) from Buurtcode
# This function extracts the first 6 digits from a standardized Buurtcode
# to create a Wijkcode, representing the district-level identifier.
extract_wijkcode <- function(buurt_code) {
  # Ensure the Buurtcode is standardized (8 digits)
  buurt_code <- standardize_buurtcode(buurt_code)
  # Extract the first 6 characters as the Wijkcode
  return(substr(buurt_code, 1, 6))
}

# Function to generate Gemeentecode (4 digits) from Buurtcode
# This function extracts the first 4 digits from a standardized Buurtcode
# to create a Gemeentecode, representing the municipality-level identifier.
extract_gemeentecode <- function(buurt_code) {
  # Ensure the Buurtcode is standardized (8 digits)
  buurt_code <- standardize_buurtcode(buurt_code)
  # Extract the first 4 characters as the Gemeentecode
  return(substr(buurt_code, 1, 4))
}

# Function to apply code standardization to a data frame
# This function standardizes the Buurtcode and generates corresponding
# Wijkcode (6 digits) and Gemeentecode (4 digits) for every row in the data frame.
# Input: 
#   - df: A data frame containing geographic codes.
#   - code_column: The column name containing Buurtcodes (default: "Buurtcode").
# Output:
#   - A data frame with three new standardized columns:
#       - buurt_code_eight_digits: Standardized Buurtcode (8 digits)
#       - wijk_code_six_digits: Extracted Wijkcode (6 digits)
#       - gemeente_code_four_digits: Extracted Gemeentecode (4 digits)
standardize_codes <- function(df, code_column = "Buurtcode") {
  # Apply the standardization functions to the specified column
  df <- df %>%
    mutate(
      buurt_code_eight_digits = sapply(.data[[code_column]], standardize_buurtcode), # Standardize Buurtcode
      wijk_code_six_digits = sapply(.data[[code_column]], extract_wijkcode),        # Generate Wijkcode
      gemeente_code_four_digits = sapply(.data[[code_column]], extract_gemeentecode) # Generate Gemeentecode
    )
  
  # Return the updated data frame with standardized codes
  return(df)
}

# Example usage (to be removed in the final script):
# Example data frame containing Buurtcodes of varying lengths
# score <- data.frame(Buurtcode = c(12345, 123456, 1234567, 12345678))
# Apply the standardize_codes function to the data frame
# standardized_score <- standardize_codes(score)
# Print the resulting standardized data frame
# print(standardized_score)
