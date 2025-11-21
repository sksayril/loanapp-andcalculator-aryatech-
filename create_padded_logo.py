"""
Script to create a padded version of the logo for app icon.
This ensures the logo fits within the adaptive icon safe zone (center 66%).
"""
from PIL import Image
import os

def create_padded_logo(input_path, output_path, padding_percent=20):
    """
    Create a padded version of the logo.
    
    Args:
        input_path: Path to the original logo image
        output_path: Path to save the padded logo
        padding_percent: Percentage of padding to add (default 20% = 17% on each side)
    """
    # Open the original image
    img = Image.open(input_path)
    
    # Convert to RGB if needed (remove alpha channel for JPEG compatibility)
    if img.mode in ('RGBA', 'LA', 'P'):
        # Create a white background
        background = Image.new('RGB', img.size, (255, 255, 255))
        if img.mode == 'P':
            img = img.convert('RGBA')
        background.paste(img, mask=img.split()[-1] if img.mode == 'RGBA' else None)
        img = background
    elif img.mode != 'RGB':
        img = img.convert('RGB')
    
    # Calculate padding
    # For adaptive icons, safe zone is ~66%, so we want logo to be ~66% of image
    # This means ~17% padding on each side
    width, height = img.size
    padding = int(min(width, height) * (padding_percent / 100))
    
    # Create new image with padding (white background)
    new_width = width + (padding * 2)
    new_height = height + (padding * 2)
    
    # Create white background
    padded_img = Image.new('RGB', (new_width, new_height), (255, 255, 255))
    
    # Paste original image in the center
    padded_img.paste(img, (padding, padding))
    
    # Save the padded image
    padded_img.save(output_path, 'JPEG', quality=95)
    print(f"[OK] Created padded logo: {output_path}")
    print(f"  Original size: {width}x{height}")
    print(f"  Padded size: {new_width}x{new_height}")
    print(f"  Padding: {padding}px on each side")

if __name__ == "__main__":
    # Paths
    input_logo = "assets/notesimages/logo2.jpeg"
    output_logo = "assets/notesimages/logo2_padded.jpeg"
    
    # Check if input exists
    if not os.path.exists(input_logo):
        print(f"Error: {input_logo} not found!")
        exit(1)
    
    # Create output directory if it doesn't exist
    os.makedirs(os.path.dirname(output_logo), exist_ok=True)
    
    # Create padded logo with 20% padding (ensures logo fits in safe zone)
    create_padded_logo(input_logo, output_logo, padding_percent=20)
    print("\nNext steps:")
    print("1. Update pubspec.yaml to use 'logo2_padded.jpeg'")
    print("2. Run: dart run flutter_launcher_icons")
    print("3. Rebuild your app")

