To change a datasource's name, you must:

1. Have `create_before_destroy = true` in a `lifecycle` block for that datasource
2. `terraform taint` the old datasource

Otherwise, it will fail to change the datasource name because resolvers are linked to it.