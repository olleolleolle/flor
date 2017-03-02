
# patterns.md

## introduction

The [Workflow Patterns](http://www.workflowpatterns.com/) are a catalog of various building blocks for workflow execution.

The main section of the Workflow Patterns is the [Control-Flow Patterns](http://www.workflowpatterns.com/patterns/control/).

Described here are ways to implement each of those control-flow patterns with flor. Some of them are not directly realizable with flor, approximations are proposed. This is a self-evaluation, for an authoritative voice, the workflow patterns website and its [mailing list](http://groups.google.com/group/workflow-patterns) are here.

Each pattern is illustrated with a flor implementation (or approximation). There is a link to the original pattern explanation and its flash animation.

## index

### Basic Control Flow Patterns
* [Sequence](#bcf-sequence)
* [Parallel Split](#bcf-parallel-split)
* [Synchronization](#bcf-synchronization)
* [Exclusive Choice](#bcf-exclusive-choice)
* simple merge

### Advanced Branching and Synchronization Patterns
* multi choice
* structured synchronizing merge
* multi merge
* structured discriminator
* Structural Patterns
* arbitrary cycles
* implicit termination

### Multiple Instance Patterns
* multiple instances without synchronization
* multiple instances with a priori design time knowledge
* multiple instances with a priori run time knowledge
* multiple instances without a priori run time knowledge

### State-based Patterns
* deferred choice
* interleaved parallel routing
* milestone

### Cancellation Patterns
* cancel task
* cancel case

### New Control Flow Patterns
(coming soon)

## Basic Control Flow Patterns

### Sequence
<a id="bcf-sequence" />Chaining activities in sequence.

Use the [sequence](procedures/sequence.md) or [cursor](procedures/cursor.md).

```
sequence
  task 'alpha'
  task 'bravo'
```

[wp/explanation](http://www.workflowpatterns.com/patterns/control/basic/wcp1.php) | [wp/animation](http://www.workflowpatterns.com/patterns/control/basic/wcp1_animation.php) | [top](#top)

### Parallel Split
<a id="bcf-parallel-split" />The [concurrence](procedures/concurrence.md) is the main tool for the parallel split.

```
concurrence
  #
  # alpha and bravo will be tasked concurrently
  #
  task 'alpha'
  task 'bravo'
```

[wp/explanation](http://www.workflowpatterns.com/patterns/control/basic/wcp2.php) | [wp/animation](http://www.workflowpatterns.com/patterns/control/basic/wcp2_animation.php) | [top](#top)

### Synchronization
<a id="bcf-synchronization" />The [concurrence](procedures/concurrence.md) by waiting (by default) for all its children to reply is usual flor syncrhonization tool.

```
sequence
  task 'alpha'
  concurrence
    task 'bravo'
    task 'charly'
    #
    # task 'delta' will be reached once 'bravo' and 'charly' have replied
    #
  task 'delta'
```

[wp/explanation](http://www.workflowpatterns.com/patterns/control/basic/wcp3.php) | [wp/animation](http://www.workflowpatterns.com/patterns/control/basic/wcp3_animation.php) | [top](#top)

### Exclusive Choice
<a id="bcf-exclusive-choice" />The simplest flor procedure to use to support this pattern is [if](procedures/if.md)

[wp/explanation](http://www.workflowpatterns.com/patterns/control/basic/wcp4.php) | [wp/animation](http://www.workflowpatterns.com/patterns/control/basic/wcp4_animation.php) | [top](#top)
