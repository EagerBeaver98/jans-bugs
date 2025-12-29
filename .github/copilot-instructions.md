# Copilot Instructions: jans-bugs (Godot 4.5)

## Project Overview
A 3D bug collection game built in Godot 4.5. The player controls a character in a first-person perspective to collect bugs on a large ground plane. Main scene is `main.tscn` with player and camera as separate script-driven components.

## Architecture & Key Components

### Scene Hierarchy
- **Main** (`main.tscn`): Root scene containing ground, lighting, and player instance
  - **Ground**: 600x600 StaticBody3D with collision - the play area
  - **DirectionalLight3D**: Casts shadows (shadow_enabled=true)
  - **Player**: CharacterBody3D instance (from `player.tscn`)
    - **Pivot**: Node3D that rotates to face movement direction (handles input rotation)
    - **Squid**: Instanced 3D model (player.glb)
    - **CollisionShape3D**: SphereShape3D for character collision
  - **Camera3D**: Attached to Player, runs `camera_3d.gd` script

### Script Structure

**`player.gd`** (CharacterBody3D)
- Handles input processing with deadzone-aware actions: move_forward/back/left/right, jump
- Uses `_physics_process(delta)` for frame-independent physics
- Exported properties: `speed` (10), `fall_acceleration` (100)
- Movement: normalizes input direction, applies to target_velocity (x/z axes)
- Gravity: applies fall_acceleration to y-axis when not on floor
- **Critical Pattern**: Input direction is normalized then applied to velocity components separately (not as a single direction vector). Jump adds y velocity directly.
- Rotation: `$Pivot.basis = Basis.looking_at(input_direction)` - pivot rotates to face movement

**`camera_3d.gd`** (Camera3D)
- Currently empty stub - defined but not implemented

### Input Mapping
Located in `project.godot`:
- **move_forward**: W key / Up arrow
- **move_back**: S key / Down arrow  
- **move_left**: A key / Left arrow
- **move_right**: D key / Right arrow
- **jump**: Space
- **rotate_cam_left**: (defined but mapping cut off in config)

All inputs use 0.2 deadzone.

## Developer Workflow

### Running the Game
- Press F5 in Godot editor or click Run button - launches main.tscn as configured in project.godot
- Debug: Use Godot's built-in debugger (F6 for pause)

### Common Tasks

**Add Camera Controls**: Implement `camera_3d.gd` to respond to rotate_cam_left/rotate_cam_right inputs and modify Camera3D.rotation_y or use look_at()

**Add Bug Spawning**: Create Area3D nodes in main.tscn with trigger scripts. Connect with signal-based pickup detection in player.gd or use area_entered signal

**Physics Tweaking**: Adjust Player's exported properties (speed, fall_acceleration) in inspector - no hardcoded values

**Model Animation**: Squid model (player.glb) is already instanced at `Player/Pivot/Squid`. Add animation playback via AnimationPlayer on Pivot or Squid node

## Code Patterns & Conventions

- **Physics Process**: Always use `_physics_process(delta)` not `_process()` for character movement
- **Relative Movement**: Input directions are applied to velocity components independently, allowing strafing (can move diagonally while facing different direction)
- **Basis Rotation**: `Basis.looking_at(direction)` is the standard for orienting characters to movement
- **Exported Variables**: Use `@export` with type hints and default values - avoid magic numbers in code
- **Transform3D**: Player stores orientation in local `orientation` variable (currently unused - suggests planned camera follow)

## File Organization
```
res://
  main.tscn              # Main scene (Ground + Player + Camera)
  player.tscn            # Player scene (Pivot + Squid model + Collision)
  player.gd              # Player controller (movement + input)
  camera_3d.gd           # Camera controller (empty stub)
  player.glb             # 3D squid model (imported)
  project.godot          # Engine config + input mappings
  assets/
    icon.svg             # Project icon
    resurrect-64.gpl     # Gimp color palette
```

## Notes for Agents
- The `$Pivot` node pattern (accessing child nodes via script) is used instead of NodePaths - maintain this style
- When adding features, preserve the separation: player movement in `player.gd`, camera in `camera_3d.gd`
- The `orientation` variable in player.gd is defined but unused - likely intended for camera-relative movement (not yet implemented)
- Input actions are well-named in project.godot; define new actions there when adding features rather than hardcoding key codes
