# k8s-object-diff

This action compares manifests for each corresponding object.

## Inputs

### `left`

**Required** Left manifest file.

### `right`

**Required** Right manifest file.

### `diff`

Diff command.

## Outputs

### `status`

Exit status, 0 if left = right, 1 if left != right, otherwise trouble.

### `ids`

List of id of objects with diff, separated by space.
