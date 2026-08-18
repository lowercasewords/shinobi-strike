# Bidirectional Coupling: Analysis & Refactoring Strategies

## Current Problem

```
Ninja ←→ State (Bidirectional)
  ├─ Ninja owns StateMachine (dependency)
  ├─ State owns ninja_owner reference (dependency)
  └─ Creates circular dependency concerns
```

### Coupling Violations
1. States access Ninja's internals: `ninja_owner.velocity`, `ninja_owner.animation_player`
2. States reach through multiple layers: `ninja_owner.ninja_controller.get_input_pressing_jump()`
3. States have tight knowledge of Ninja structure
4. Changes to Ninja API break all states

---

## Strategy 1: Observer/Signal Pattern

### Concept
States emit **signals** instead of directly modifying Ninja. Ninja listens and applies changes.

### Advantages
✓ Complete decoupling (no direct references)
✓ Event-driven architecture
✓ Easy to add new listeners
✓ Clear intent through signal names

### Disadvantages
✗ More verbose (signal definitions everywhere)
✗ Harder to debug state flow
✗ Performance overhead (signal emission)
✗ Delayed feedback (async nature)

### Example
```gdscript
# In State
signal animation_requested(animation_name: String)
signal velocity_changed(new_velocity: Vector2)

func enter():
    animation_requested.emit("idle")

# In Ninja (listens)
state_machine.current_state.animation_requested.connect(_on_state_animation_requested)
func _on_state_animation_requested(anim: String):
    set_animation(anim)
```

---

## Strategy 2: Dependency Injection via StateContext Interface ⭐ RECOMMENDED

### Concept
Create an abstract **StateContext** interface that Ninja implements. Pass context to states instead of direct parent reference.

### Advantages
✓ Reduces coupling (interface-based)
✓ Ninja implementation detail hidden
✓ Easy to mock for testing
✓ Minimal code changes
✓ Maintains performance (no signals)
✓ Clear API contract

### Disadvantages
✗ Requires creating interface class
✗ Slight initial refactoring overhead
✗ Still allows direct property access (if not careful)

### Example
```gdscript
# StateContext.gd - Interface
class_name StateContext
func get_velocity() -> Vector2: pass
func set_velocity(v: Vector2) -> void: pass
func request_animation(name: String) -> void: pass
func request_state_change(name: String) -> void: pass
# ... etc

# In State
@onready var context: StateContext = owner
func enter():
    context.request_animation("idle")
    context.set_velocity(Vector2.ZERO)
```

---

## Strategy 3: Facade/Command Pattern (Limited API)

### Concept
Ninja exposes a **limited, carefully-designed API** for state requests. States only use facade methods.

### Advantages
✓ Moderate decoupling improvement
✓ Simple to implement (no new classes)
✓ Explicit API boundaries
✓ States don't reach deep into Ninja

### Disadvantages
✗ Partial solution (still bidirectional)
✗ Requires discipline to maintain facade
✗ Can become bloated with methods
✗ Doesn't address root coupling

### Example
```gdscript
# In Ninja (Facade methods)
func request_state_transition(state_name: String) -> void:
    state_machine.transition_state(current_state, state_name)

func request_animation(anim_name: String) -> void:
    set_animation(anim_name)

func request_velocity_change(new_velocity: Vector2) -> void:
    velocity = new_velocity

# In State
func enter():
    ninja_owner.request_animation("idle")
    ninja_owner.request_velocity_change(Vector2.ZERO)
```

---

## Recommendation

**Implement Strategy 2 (StateContext) + Strategy 3 (Facade)**:
1. Create `StateContext` interface for abstraction
2. Add facade methods to Ninja for state requests
3. Refactor states to use context instead of owner
4. Gradual migration (doesn't require rewriting everything)

This approach:
- Decouples architecture (interface-based)
- Maintains performance
- Provides clear contracts
- Allows gradual refactoring
