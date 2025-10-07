# Other Miscellaneous Dotfiles Stuff

## Shortcuts

- [BtrFS Snapshot System](#btrfs-snapshot-system)

## BtrFS Snapshot System

For my BtrFS snapshots,
I like to create a snapshot weekly with a max of 3 snapshots at a time.
This means that I could go back 3 weeks in time if I wanted to.
To achieve this, I utilize [Snapper](https://wiki.archlinux.org/title/Snapper) and systemd services.

### Snapper Config File

This file's fullpath is `/etc/snapper/configs/dvt`.

```snapper
# subvolume to snapshot
SUBVOLUME="/"

# filesystem type
FSTYPE="btrfs"

# fraction or absolute size of the filesystems space the snapshots may use
SPACE_LIMIT="0.2"

# fraction or absolute size of the filesystems space that should be free
FREE_LIMIT="0.2"


# users and groups allowed to work with config
ALLOW_USERS="dvt"
ALLOW_GROUPS=""

# sync users and groups from ALLOW_USERS and ALLOW_GROUPS to .snapshots
# directory
SYNC_ACL="yes"


# start comparing pre- and post-snapshot in background after creating
# post-snapshot
BACKGROUND_COMPARISON="yes"


# run daily number cleanup
NUMBER_CLEANUP="yes"

# limit for number cleanup
NUMBER_MIN_AGE="0"
NUMBER_LIMIT="3"
NUMBER_LIMIT_IMPORTANT="1"


# create hourly snapshots
TIMELINE_CREATE="no"

# cleanup hourly snapshots after some time
TIMELINE_CLEANUP="no"

# cleanup empty pre-post-pairs
EMPTY_PRE_POST_CLEANUP="yes"

QGROUP="1/0"
```

### SystemD Service File

This file's fullpath is `/etc/systemd/system/snapper-weekly@.service`.

```service
[Unit]
Description=Weekly Snapper snapshot for %i

[Service]
Type=oneshot
ExecStart=/usr/bin/snapper -c %i create --description "weekly auto snapshot" --cleanup-algorithm number
ExecStartPost=/usr/bin/snapper -c %i cleanup number
```

### SystemD Timer File

This file's fullpath is `/etc/systemd/system/snapper-weekly@.timer`.

```service
[Unit]
Description=Weekly Snapper snapshot timer for %i

[Timer]
OnCalendar=weekly
Persistent=true

[Install]
WantedBy=timers.target
```

### SystemD Enable The Weekly Snapshots

```shell
sudo systemctl enable --now snapper-weekly@dvt.timer
```
