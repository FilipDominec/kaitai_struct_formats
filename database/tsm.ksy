meta:
  id: tsm
  title: InfluxDB TSM file
  license: MIT
  file-extension: tsm
  endian: be

seq:
  - id: header
    type: header

types:

  header:
    seq:
      - id: magic
        contents: [0x16, 0xd1, 0x16, 0xd1]
      - id: version
        type: u1

  index:
    seq:
      - id: offset
        type: u8

    instances:
      entries:
        pos: offset
        repeat: until
        repeat-until: _io.pos == _io.size - 8
        type: index_header

    types:
      index_header:
          seq:
            - id: key_len
              type: u2
            - id: key
              type: str
              encoding: UTF-8
              size: key_len
            - id: type
              type: u1
            - id: entry_count
              type: u2

            - id: index_entries
              type: index_entry
              repeat: expr
              repeat-expr: entry_count

          types:
            index_entry:
              seq:
                - id: min_time
                  type: u8
                - id: max_time
                  type: u8
                - id: block_offset
                  type: u8
                - id: block_size
                  type: u4

              types:
                block_entry:
                  seq:
                    - id: crc32
                      type: u4
                    - id: data
                      size: _parent.block_size - 4

              instances:
                block:
                  io: _root._io
                  type: block_entry
                  pos: block_offset

instances:
  index:
    type: index
    pos: _io.size - 8
