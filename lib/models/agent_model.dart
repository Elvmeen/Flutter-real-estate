class Agent {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String city;

  const Agent({required this.id, required this.name, required this.email, required this.phone, required this.city});
}

const demoAgents = <Agent>[
  Agent(id: 'a1', name: 'Alex Johnson', email: 'alex@example.com', phone: '+1 555 0100', city: 'Amsterdam'),
  Agent(id: 'a2', name: 'Maria Gomez', email: 'maria@example.com', phone: '+1 555 0101', city: 'Rotterdam'),
  Agent(id: 'a3', name: 'Chen Li', email: 'chen@example.com', phone: '+1 555 0102', city: 'Utrecht'),
];
