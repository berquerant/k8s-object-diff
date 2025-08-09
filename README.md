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

## Usage

``` yaml
jobs:
  objdiff_job:
    runs-on: ubuntu-latest
    name: k8s-object-diff
    steps:
      - name: Diff manifests
        uses: berquerant/k8s-object-diff@v0.2.0
        id: objdiff
        with:
          left: left.yml
          right: right.yml
      - name: Show status
        run: echo "status was ${{ steps.objdiff.outputs.status }}"
```
