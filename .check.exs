[
  parallel: true,
  tools: [
    {:compiler, command: "mix compile --force"},
    {:doctor, false},
    {:ex_doc, false},
    {:gettext, false},
    {:mix_audit, false},
    {:sobelow, false}
  ]
]
