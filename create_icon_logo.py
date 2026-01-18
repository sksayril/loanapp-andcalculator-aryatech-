"""
Script to create a properly sized logo for app icon.
This ensures the logo fits within the adaptive icon safe zone (center 66%).
The logo will be smaller with padding around it.
"""
from PIL import Image
import os

def create_icon_logo(input_path, output_path, logo_size_percent=60):
    """
    Create a properly sized logo for app icon with padding.
    
    Args:
        input_path: Path to the original logo image
        output_path: Path to save the icon logo
        logo_size_percent: Percentage of the image the logo should occupy (default 60% = fits in safe zone)
    """
    # Open the original image
    img = Image.open(input_path)
    
    # Convert to RGB if needed
    if img.mode in ('RGBA', 'LA', 'P'):
        # Create a transparent background for PNG, or colored for adaptive icon
        if img.mode == 'P':
            img = img.convert('RGBA')
        # For adaptive icons, we want transparent background
        if img.mode == 'RGBA':
            # Keep transparency
            pass
        else:
            background = Image.new('RGB', img.size, (106, 27, 154))  # Purple #6A1B9A
            background.paste(img, mask=img.split()[-1] if img.mode == 'RGBA' else None)
            img = background
    elif img.mode != 'RGB':
        img = img.convert('RGB')
    
    # For adaptive icons, create a square canvas
    # Standard adaptive icon size is 1024x1024
    canvas_size = 1024
    
    # Calculate logo size based on percentage
    logo_size = int(canvas_size * (logo_size_percent / 100))
    
    # Resize the logo to fit within the safe zone
    img.thumbnail((logo_size, logo_size), Image.Resampling.LANCZOS)
    
    # Create a square canvas with transparent background (or purple for adaptive icon)
    # For adaptive icon foreground, we use transparent background
    if img.mode == 'RGBA':
        canvas = Image.new('RGBA', (canvas_size, canvas_size), (0, 0, 0, 0))
    else:
        # If no alpha channel, create one with transparent background
        canvas = Image.new('RGBA', (canvas_size, canvas_size), (0, 0, 0, 0))
        # Convert img to RGBA
        if img.mode != 'RGBA':
            img_rgba = Image.new('RGBA', img.size)
            img_rgba.paste(img)
            img = img_rgba
    
    # Calculate position to center the logo
    x_offset = (canvas_size - img.size[0]) // 2
    y_offset = (canvas_size - img.size[1]) // 2
    
    # Paste the logo in the center
    canvas.paste(img, (x_offset, y_offset), img if img.mode == 'RGBA' else None)
    
    # Save as PNG to preserve transparency
    canvas.save(output_path, 'PNG')
    print(f"[OK] Created icon logo: {output_path}")
    print(f"  Canvas size: {canvas_size}x{canvas_size}")
    print(f"  Logo size: ~{logo_size_percent}% of canvas (fits in safe zone)")

if __name__ == "__main__":
    # Paths
    input_logo = "assets/notesimages/loankinglogo.jpeg"
    output_logo = "assets/notesimages/loankinglogo_icon.png"
    
    # Check if input exists
    if not os.path.exists(input_logo):
        print(f"Error: {input_logo} not found!")
        exit(1)
    
    # Create output directory if it doesn't exist
    os.makedirs(os.path.dirname(output_logo), exist_ok=True)
    
    # Create icon logo with 60% size (fits comfortably in 66% safe zone)
    create_icon_logo(input_logo, output_logo, logo_size_percent=60)
    print("\nNext steps:")
    print("1. Update pubspec.yaml to use 'loankinglogo_icon.png' for adaptive_icon_foreground")
    print("2. Run: flutter pub run flutter_launcher_icons")
    print("3. Rebuild your app")


