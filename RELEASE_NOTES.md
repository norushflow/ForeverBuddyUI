# v1.0.25

- Skip automatic action-bar restoration when a level-up triggers a talent update. Explicit specialization changes still restore the saved setup.
- Preserve existing macros the client cannot identify and skip them without a restore warning.
- Show the first failed action slot or a click-binding failure when manually restoring with /fbui restore.
