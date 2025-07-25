#!/usr/bin/env python3
import os
import sys
import subprocess
from pathlib import Path

# Define the icon sizes needed for macOS iconset
icon_sizes = [
    (16, "icon_16x16.png"),
    (32, "icon_16x16@2x.png"),
    (32, "icon_32x32.png"),
    (64, "icon_32x32@2x.png"),
    (128, "icon_128x128.png"),
    (256, "icon_128x128@2x.png"),
    (256, "icon_256x256.png"),
    (512, "icon_256x256@2x.png"),
    (512, "icon_512x512.png"),
    (1024, "icon_512x512@2x.png")
]

# Parse command line arguments
input_file = None
output_path = None

if len(sys.argv) > 1:
    input_file = sys.argv[1]
    if len(sys.argv) > 2:
        output_path = sys.argv[2]
else:
    # Check for icon.png or icon.svg
    if os.path.exists("icon.png"):
        input_file = "icon.png"
    elif os.path.exists("icon.svg"):
        input_file = "icon.svg"
    else:
        print("Error: No icon.png or icon.svg found, and no input file specified")
        print("Usage: python3 create_iconset.py [input_file] [output_path]")
        print("  input_file: Path to source icon (PNG or SVG)")
        print("  output_path: Path for output .icns file (optional, default: ./Miso.icns)")
        exit(1)

# Set default output path if not specified
if output_path is None:
    output_path = "Miso.icns"

# Extract base name for iconset directory
output_dir = os.path.dirname(output_path) or "."
base_name = os.path.splitext(os.path.basename(output_path))[0]
iconset_name = f"{base_name}.iconset"
iconset_dir = Path(output_dir) / iconset_name

print(f"Using input file: {input_file}")
print(f"Output will be: {output_path}")

# Create iconset directory if it doesn't exist
iconset_dir.mkdir(parents=True, exist_ok=True)

# Check if input is PNG or SVG
is_png = input_file.lower().endswith('.png')
is_svg = input_file.lower().endswith('.svg')

if is_png:
    print("Processing PNG file...")
    # For PNG, directly use sips to resize
    for size, filename in icon_sizes:
        icon_path = iconset_dir / filename
        print(f"Creating {filename} ({size}x{size})...")
        subprocess.run([
            "sips", "-z", str(size), str(size), input_file,
            "--out", str(icon_path)
        ], capture_output=True)
        
elif is_svg:
    # Try to use cairosvg if available
    try:
        import cairosvg
        print("Using cairosvg for SVG conversion...")
        
        for size, filename in icon_sizes:
            icon_path = iconset_dir / filename
            print(f"Creating {filename} ({size}x{size})...")
            cairosvg.svg2png(
                url=input_file,
                write_to=str(icon_path),
                output_width=size,
                output_height=size
            )
        
    except ImportError:
        print("cairosvg not found. Using qlmanage (macOS built-in)...")
        
        # First convert SVG to PNG using qlmanage
        temp_png = "temp_icon.png"
        subprocess.run([
            "qlmanage", "-t", "-s", "1024", "-o", ".", input_file
        ], capture_output=True)
        
        # Move the generated file
        generated_file = f"{input_file}.png"
        if os.path.exists(generated_file):
            os.rename(generated_file, temp_png)
        else:
            print("Error: Could not generate PNG from SVG")
            exit(1)
        
        # Now use sips to resize to all required sizes
        for size, filename in icon_sizes:
            icon_path = iconset_dir / filename
            print(f"Creating {filename} ({size}x{size})...")
            subprocess.run([
                "sips", "-z", str(size), str(size), temp_png,
                "--out", str(icon_path)
            ], capture_output=True)
        
        # Clean up temp file
        os.remove(temp_png)
else:
    print(f"Error: Unsupported file format. Please use .png or .svg files")
    exit(1)

print("\nIcon PNG files created successfully!")

# Generate the .icns file
print("\nGenerating .icns file...")
result = subprocess.run([
    "iconutil", "-c", "icns", str(iconset_dir), "-o", output_path
], capture_output=True, text=True)

if result.returncode == 0:
    print(f"{output_path} created successfully!")
    # Clean up the iconset directory if desired
    # import shutil
    # shutil.rmtree(iconset_dir)
else:
    print(f"Error creating .icns file: {result.stderr}")