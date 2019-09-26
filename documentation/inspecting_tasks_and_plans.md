# Inspecting tasks and plans

Before you run tasks or plans in your environment, inspect them to determine what effect they will have on your target nodes.

**Tip**: Bolt is packaged with a collection of modules that contain useful plans to support common workflows. For details, see [Packaged modules](bolt_installing_modules.md#packaged-modules).

## Run in no operation mode

You can run some tasks in no-operation mode \(`noop`\) to view changes without taking any action on your target nodes. This way, you ensure the tasks perform as designed. If a task doesn't support no-operation mode, you'll get an error.

```
bolt task run package name=vim action=install --noop -n example.com
```

## Show a task list

View a list of what tasks are installed in the current module path. Note that tasks marked with the `private` metadata key will not be shown:

```
bolt task show
```

## Show documentation for a task

View parameters and other details for a task, including whether a task supports `--noop`:

```
bolt task show <TASK NAME>
```

## Discover plans

View a list of what plans are installed on the current module path:

```
bolt plan show
```

## Show documentation for a plan

View parameters and other details for a plan, including whether a plan supports `--noop`:

```
bolt plan show <PLAN NAME>
```

