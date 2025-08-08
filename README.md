# Godot Textmod

A modding API addon for Godot that can be set up almost entirely through the inspector with minimal code. It even generates documentation for your modding API automatically.

Godot Textmod is inspired by the textmod feature from Slice & Dice. I absolutley recommend checking Slice & Dice out on Steam.

## What is this?

This addon lets you create a modding API for your game using simple text commands. Players can write something like:

```
hero.name.John.health.100.items.sword.hair_color.#FF0000
```

And it'll modify your game resources accordingly. You set it up through Godot's inspector, and it even generates documentation for your modding API automatically.

## Installation

1. **Download the latest release** from the [Releases page](https://github.com/greenpixels/godot-textmod/releasess)
2. **Extract the zip file** - you'll get a `textmod/` folder
3. **Copy to your project** - place the `textmod/` folder in your Godot project's `addons/` directory

Your project structure should look like:
```
your-project/
├── addons/
│   └── textmod/
│       ├── core/
│       ├── impl/
│       └── userland/
└── ... (your other files)
```

## How It Works

Textmod uses a **parser-based system** with three main components:

### 1. Parser (TextmodParser)
The main component that processes text input. You need to create a parser somewhere in your scene and configure it with bases.

### 2. Bases (TextmodBase) 
Define what objects can be modified. Each base has:
- A **key** (identifier like "hero")
- A **resource type** to create/modify
- **Possible modifiers** that can be applied

### 3. Modifiers (TextmodModifier)
Define what properties can be changed. Each modifier has:
- A **key** (identifier like "name", "health")
- A **value parser** (determines what values are accepted)
- A **pipe script** (applies the value to the resource)

## Basic Usage

### Step 1: Add a Parser Node

Add a `TextmodParser` node to your scene (it's available in the "Create Node" dialog after installation).

### Step 2: Set Up Bases and Modifiers in the Inspector

With your TextmodParser node selected, look at the Inspector:

1. **Create a Base**: In the "Bases" array, add a new element
   - Set the **Textmod Key** (e.g., "hero")
   - Set the **Resource To Modify** to your resource script (e.g., Hero.gd)

2. **Add Modifiers**: In the "Possible Modifiers" array of your base, add elements:
   - **Name Modifier**: 
     - Textmod Key: "name"
     - Value Parser: TextmodValueParserText
     - Pipe Script: TextmodPipeSimpleSetter
   - **Health Modifier**:
     - Textmod Key: "health"  
     - Value Parser: TextmodValueParserNumber
     - Pipe Script: TextmodPipeSimpleSetter

### Step 3: Parse Text

```swift
# Connect to parser signals
textmod_parser.parse_success.connect(_on_parse_success)
textmod_parser.parse_error.connect(_on_parse_error)

# Parse text input
textmod_parser.parse_from_text("hero.name.Alice.health.150")

func _on_parse_success(result):
    print("Successfully created/modified: ", result)
    # result is your modified Hero resource

func _on_parse_error(message: String):
    print("Parse error: ", message)
```

## Text Syntax

### Basic Format
```
base.modifier.value.modifier.value
```

### Examples
```
# Simple hero modification
hero.name.John.health.100

# Multiple items (using array push pipe)
hero.items.sword.items.shield.items.potion

# Colors (hex values)
hero.hair_color.#FF0000.eye_color.#0000FF

# Text with dots (use quotes)
hero.name."Klaus.Dieter".location."St. Mary's"

# Numbers (integers and decimals)
hero.health.100.experience.1250.damage.25.5
```

### Value Types

The system includes several built-in value parsers:

- **TextmodValueParserText**: Any text (use quotes for text containing dots)
- **TextmodValueParserNumber**: Integers and decimals (42, 3.14, -10)
- **TextmodValueParserColor**: Hex colors (#FF0000, #ABC, FFFFFF)
- **TextmodValueParserTexture**: Base64-encoded PNG images

## Advanced Features

### Custom Value Parsers
Create your own value parsers by extending `TextmodValueParser`:

```swift
class_name MyCustomParser
extends TextmodValueParser

func parse(value: String, part: TextmodPart) -> Variant:
    # Your parsing logic here
    return parsed_value

func get_docs_examples() -> Array[String]:
    return ["example1", "example2"]

func get_docs_description() -> String:
    return "Description of expected input format"
```

### Custom Pipe Scripts
Create custom pipe scripts by extending `TextmodPipeScript`:

```swift
class_name MyCustomPipe
extends TextmodPipeScript

func pipe(input: Resource, value: Variant, part: TextmodPart) -> Variant:
    # Apply value to input resource
    return input
```

### Documentation Generation
Generate documentation for your textmod setup:

```swift
# Create a documentation generator
var doc_generator = TextmodAutodocBBCode.new()
doc_generator.parser = textmod_parser

# Connect to signal
doc_generator.docs_generated.connect(_on_docs_generated)

# Generate documentation
doc_generator.generate()

func _on_docs_generated(bbcode: String):
    # Use bbcode in a RichTextLabel
    $DocumentationLabel.text = bbcode
```

Available documentation formats:
- `TextmodAutodocBBCode` - For Godot RichTextLabel
- `TextmodAutodocMarkdown` - For Markdown files  
- `TextmodAutodocHTML` - For web documentation

## Examples

Check the `examples/` folder for complete implementation examples, including:
- Hero character modification system
- Save/load functionality
- Documentation generation

## Contributing

Contributions are welcome! Please feel free to submit issues, feature requests, or pull requests.
