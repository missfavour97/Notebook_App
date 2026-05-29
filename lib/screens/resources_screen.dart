import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../controllers/subject_controller.dart';
import '../controllers/task_controller.dart';

class ResourcesScreen extends StatefulWidget {
  final String selectedField;

  const ResourcesScreen({super.key, required this.selectedField});

  @override
  State<ResourcesScreen> createState() => _ResourcesScreenState();
}

class _ResourcesScreenState extends State<ResourcesScreen> {
  final SubjectController subjectController = SubjectController();
  final TaskController taskController = TaskController();

  String selectedCategory = 'Toolkit';

  List<String> get categories => const ['Toolkit', 'Templates', 'Study Moves'];

  List<_ResourceItem> get resources {
    final shared = [
      _ResourceItem(
        category: 'Toolkit',
        title: 'Study Plan Builder',
        description: 'Turn a topic list into a weekly plan with checkpoints.',
        icon: Icons.event_note,
        quickTask: 'Build a weekly study plan',
        prompt:
            'Create a study plan for this subject. Include topics, deadlines, weak areas, and daily review blocks.',
        steps: const [
          'List the topics you must cover.',
          'Mark each topic as easy, medium, or hard.',
          'Turn hard topics into shorter review blocks.',
          'Add one checkpoint after every two sessions.',
        ],
      ),
      _ResourceItem(
        category: 'Templates',
        title: 'Revision Page',
        description: 'A reusable note pattern for active recall.',
        icon: Icons.fact_check,
        quickTask: 'Create a revision page',
        prompt:
            'Make a revision page with key ideas, mistakes to avoid, practice questions, and a final summary.',
        steps: const [
          'Write the topic in one sentence.',
          'Add five key ideas from memory.',
          'Add three questions you could be asked.',
          'End with one thing you still do not understand.',
        ],
      ),
      _ResourceItem(
        category: 'Study Moves',
        title: 'Recall Sprint',
        description: 'A short session for testing memory before reading again.',
        icon: Icons.timer,
        quickTask: 'Run a 15-minute recall sprint',
        prompt:
            'Test me on this topic using short-answer questions first, then show corrections and a score.',
        steps: const [
          'Close the note or book.',
          'Write everything remembered for five minutes.',
          'Compare against the source.',
          'Save only the missed ideas as follow-up tasks.',
        ],
      ),
    ];

    return [..._fieldResources(widget.selectedField), ...shared];
  }

  List<_ResourceItem> get filteredResources {
    return resources
        .where((resource) => resource.category == selectedCategory)
        .toList();
  }

  List<_ResourceItem> _fieldResources(String field) {
    switch (field) {
      case 'Accounting':
        return const [
          _ResourceItem(
            category: 'Toolkit',
            title: 'Ledger Workout',
            description: 'Practice debits, credits, and account balancing.',
            icon: Icons.calculate,
            quickTask: 'Practice five ledger entries',
            prompt:
                'Give me five accounting transactions and walk me through debit, credit, and final ledger balance.',
            steps: [
              'Identify affected accounts.',
              'Classify each account type.',
              'Choose debit or credit.',
              'Check that both sides balance.',
            ],
          ),
          _ResourceItem(
            category: 'Templates',
            title: 'Financial Statement Page',
            description:
                'A note layout for income statement and balance sheet.',
            icon: Icons.assessment,
            quickTask: 'Draft a financial statement summary',
            prompt:
                'Create a financial statement note with formulas, line items, examples, and common mistakes.',
            steps: [
              'Separate income statement and balance sheet items.',
              'Write formulas beside each section.',
              'Add one worked example.',
              'Add errors to watch for.',
            ],
          ),
        ];
      case 'Finance':
        return const [
          _ResourceItem(
            category: 'Toolkit',
            title: 'Valuation Sheet',
            description: 'Build finance notes around assumptions and formulas.',
            icon: Icons.trending_up,
            quickTask: 'Review a valuation formula',
            prompt:
                'Explain this valuation problem by listing assumptions, formula, substitution, answer, and interpretation.',
            steps: [
              'Write the formula first.',
              'Define every variable.',
              'Add the calculation.',
              'Explain what the result means.',
            ],
          ),
          _ResourceItem(
            category: 'Study Moves',
            title: 'Ratio Drill',
            description: 'Memorize ratios by using examples, not definitions.',
            icon: Icons.analytics,
            quickTask: 'Practice finance ratios',
            prompt:
                'Quiz me on liquidity, profitability, efficiency, and leverage ratios using real mini scenarios.',
            steps: [
              'Pick one ratio family.',
              'Write the formula from memory.',
              'Solve a tiny example.',
              'Explain whether the number is good or risky.',
            ],
          ),
        ];
      case 'Marketing':
        return const [
          _ResourceItem(
            category: 'Toolkit',
            title: 'Campaign Canvas',
            description:
                'Shape campaign ideas into audience, message, channel.',
            icon: Icons.campaign,
            quickTask: 'Sketch a campaign canvas',
            prompt:
                'Help me create a campaign canvas with target audience, offer, message, channels, budget, and success metrics.',
            steps: [
              'Define one audience segment.',
              'Write the message in plain language.',
              'Choose two channels.',
              'Pick one measurable outcome.',
            ],
          ),
          _ResourceItem(
            category: 'Templates',
            title: 'Brand Positioning Page',
            description: 'Capture promise, proof, personality, and difference.',
            icon: Icons.auto_awesome,
            quickTask: 'Write a brand positioning note',
            prompt:
                'Create a brand positioning page with problem, promise, proof, personality, and competitor difference.',
            steps: [
              'State the customer problem.',
              'Write the brand promise.',
              'Add evidence or proof.',
              'Name the competitor difference.',
            ],
          ),
        ];
      case 'Management':
        return const [
          _ResourceItem(
            category: 'Toolkit',
            title: 'Decision Log',
            description: 'Track decisions, tradeoffs, owners, and next moves.',
            icon: Icons.account_tree,
            quickTask: 'Create a decision log',
            prompt:
                'Create a decision log with context, options, criteria, selected choice, risks, and owner.',
            steps: [
              'Write the decision in one line.',
              'List two or three options.',
              'Compare tradeoffs.',
              'Assign the next action.',
            ],
          ),
          _ResourceItem(
            category: 'Study Moves',
            title: 'Case Study Breakdown',
            description: 'Analyze a management case without getting lost.',
            icon: Icons.psychology,
            quickTask: 'Break down one case study',
            prompt:
                'Break this case study into facts, problem, stakeholders, options, recommendation, and implementation plan.',
            steps: [
              'List facts only.',
              'Separate symptoms from the real problem.',
              'Name the stakeholders.',
              'Choose and defend one recommendation.',
            ],
          ),
        ];
      case 'Computer Engineering':
        return const [
          _ResourceItem(
            category: 'Toolkit',
            title: 'Algorithm Lab',
            description: 'Turn problems into pseudocode and complexity notes.',
            icon: Icons.code,
            quickTask: 'Solve one algorithm problem',
            prompt:
                'Help me solve this algorithm problem with intuition, pseudocode, complexity, edge cases, and a dry run.',
            steps: [
              'Restate the problem.',
              'Write brute force first.',
              'Improve the approach.',
              'Dry run with a small input.',
            ],
          ),
          _ResourceItem(
            category: 'Templates',
            title: 'Debug Journal',
            description: 'A note pattern for errors, hypotheses, and fixes.',
            icon: Icons.bug_report,
            quickTask: 'Document one bug fix',
            prompt:
                'Create a debug journal entry with error, suspected cause, test, result, final fix, and lesson.',
            steps: [
              'Copy the exact error.',
              'Write the first hypothesis.',
              'Record what changed.',
              'Save the final lesson.',
            ],
          ),
        ];
      case 'Mechanical Engineering':
        return const [
          _ResourceItem(
            category: 'Toolkit',
            title: 'Design Calculation Sheet',
            description: 'Structure formulas, assumptions, and safety factors.',
            icon: Icons.precision_manufacturing,
            quickTask: 'Prepare a design calculation',
            prompt:
                'Build a design calculation page with assumptions, known values, formula, substitution, result, and safety check.',
            steps: [
              'Write known values with units.',
              'State assumptions.',
              'Show formula and substitution.',
              'Check the safety factor.',
            ],
          ),
          _ResourceItem(
            category: 'Study Moves',
            title: 'Free-body Drill',
            description: 'Practice force diagrams and equilibrium thinking.',
            icon: Icons.architecture,
            quickTask: 'Practice one free-body diagram',
            prompt:
                'Give me a free-body diagram problem and guide me through forces, moments, equilibrium, and final answer.',
            steps: [
              'Draw the object alone.',
              'Add every external force.',
              'Choose axes.',
              'Write equilibrium equations.',
            ],
          ),
        ];
      case 'Electrical Engineering':
        return const [
          _ResourceItem(
            category: 'Toolkit',
            title: 'Circuit Analysis Bench',
            description: 'Organize circuit problems into nodes and loops.',
            icon: Icons.electrical_services,
            quickTask: 'Analyze one circuit',
            prompt:
                'Help me solve this circuit using known values, node/loop equations, simplification, and validation.',
            steps: [
              'Mark known values.',
              'Choose nodal or mesh analysis.',
              'Write equations clearly.',
              'Validate the answer with units.',
            ],
          ),
          _ResourceItem(
            category: 'Templates',
            title: 'Lab Measurement Log',
            description: 'Track setup, ranges, readings, and observations.',
            icon: Icons.fact_check,
            quickTask: 'Prepare an electrical lab log',
            prompt:
                'Create an electrical lab log with apparatus, setup, range settings, readings, errors, and conclusion.',
            steps: [
              'List equipment.',
              'Record meter settings.',
              'Capture readings in a table.',
              'Write one source of error.',
            ],
          ),
        ];
      case 'Medicine':
        return const [
          _ResourceItem(
            category: 'Toolkit',
            title: 'Clinical Case Builder',
            description: 'Structure cases from history to management plan.',
            icon: Icons.local_hospital,
            quickTask: 'Write one clinical case',
            prompt:
                'Create a clinical case note with history, symptoms, exam findings, differentials, diagnosis, and management.',
            steps: [
              'Collect history.',
              'Group symptoms by system.',
              'List differential diagnoses.',
              'Write the management plan.',
            ],
          ),
          _ResourceItem(
            category: 'Study Moves',
            title: 'Diagnosis Drill',
            description: 'Practice moving from symptoms to differentials.',
            icon: Icons.health_and_safety,
            quickTask: 'Practice a diagnosis drill',
            prompt:
                'Quiz me with a short patient presentation and ask me for differentials, tests, and likely diagnosis.',
            steps: [
              'Read the presentation once.',
              'Name three differentials.',
              'Choose key investigations.',
              'Defend the likely diagnosis.',
            ],
          ),
        ];
      case 'Pharmacy':
        return const [
          _ResourceItem(
            category: 'Templates',
            title: 'Drug Profile',
            description: 'Capture class, mechanism, dose, effects, warnings.',
            icon: Icons.medication,
            quickTask: 'Create a drug profile',
            prompt:
                'Create a drug profile with class, mechanism, indication, dose, adverse effects, interactions, and counseling points.',
            steps: [
              'Write the drug class.',
              'Explain mechanism simply.',
              'Add adverse effects.',
              'End with patient counseling.',
            ],
          ),
          _ResourceItem(
            category: 'Study Moves',
            title: 'Interaction Check',
            description: 'Practice spotting risky drug combinations.',
            icon: Icons.hub,
            quickTask: 'Review drug interactions',
            prompt:
                'Quiz me on drug interactions by giving medication pairs and asking for risk, mechanism, and counseling.',
            steps: [
              'Name both drugs.',
              'Identify the interaction type.',
              'State the clinical risk.',
              'Write the counseling advice.',
            ],
          ),
        ];
      case 'Nursing':
        return const [
          _ResourceItem(
            category: 'Templates',
            title: 'Care Plan',
            description: 'Assessment, goals, interventions, evaluation.',
            icon: Icons.health_and_safety,
            quickTask: 'Prepare a care plan',
            prompt:
                'Create a nursing care plan with assessment, diagnosis, goals, interventions, rationale, and evaluation.',
            steps: [
              'Write assessment cues.',
              'Choose nursing diagnosis.',
              'Set measurable goals.',
              'Add interventions and rationale.',
            ],
          ),
          _ResourceItem(
            category: 'Toolkit',
            title: 'Shift Handover Note',
            description:
                'Keep patient status, vitals, tasks, and concerns clear.',
            icon: Icons.assignment,
            quickTask: 'Draft a shift handover',
            prompt:
                'Create a shift handover note with patient status, vitals, medication, completed care, pending tasks, and concerns.',
            steps: [
              'Summarize patient status.',
              'Record vitals and meds.',
              'List completed care.',
              'Highlight pending actions.',
            ],
          ),
        ];
      default:
        return const [];
    }
  }

  Future<void> addSubjectFromResource(_ResourceItem item) async {
    await subjectController.addSubject(item.title, widget.selectedField);

    if (!mounted) return;

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('${item.title} added to Subjects')));
  }

  Future<void> addTaskFromResource(_ResourceItem item) async {
    await taskController.addTask(item.quickTask, widget.selectedField);

    if (!mounted) return;

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('${item.quickTask} added to Tasks')));
  }

  Future<void> copyPrompt(_ResourceItem item) async {
    await Clipboard.setData(ClipboardData(text: item.prompt));

    if (!mounted) return;

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Prompt copied')));
  }

  void openResource(_ResourceItem item) {
    final colorScheme = Theme.of(context).colorScheme;

    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (sheetContext) {
        return SafeArea(
          child: Padding(
            padding: EdgeInsets.only(
              left: 20,
              right: 20,
              bottom: MediaQuery.of(sheetContext).viewInsets.bottom + 20,
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: colorScheme.primaryContainer,
                        child: Icon(item.icon, color: colorScheme.primary),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.title,
                              style: Theme.of(context).textTheme.titleLarge
                                  ?.copyWith(fontWeight: FontWeight.bold),
                            ),
                            Text(
                              item.category,
                              style: TextStyle(color: colorScheme.primary),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(item.description),
                  const SizedBox(height: 18),
                  Text(
                    'How to use it',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  ...item.steps.map(
                    (step) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            Icons.check_circle,
                            size: 18,
                            color: colorScheme.primary,
                          ),
                          const SizedBox(width: 8),
                          Expanded(child: Text(step)),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(item.prompt),
                  ),
                  const SizedBox(height: 18),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: [
                      FilledButton.icon(
                        onPressed: () async {
                          Navigator.pop(sheetContext);
                          await addSubjectFromResource(item);
                        },
                        icon: const Icon(Icons.menu_book),
                        label: const Text('Add Subject'),
                      ),
                      OutlinedButton.icon(
                        onPressed: () async {
                          Navigator.pop(sheetContext);
                          await addTaskFromResource(item);
                        },
                        icon: const Icon(Icons.check_circle),
                        label: const Text('Add Task'),
                      ),
                      OutlinedButton.icon(
                        onPressed: () async {
                          Navigator.pop(sheetContext);
                          await copyPrompt(item);
                        },
                        icon: const Icon(Icons.copy),
                        label: const Text('Copy Prompt'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final items = filteredResources;

    return Scaffold(
      appBar: AppBar(title: const Text('Study Studio')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Container(
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              color: colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(18),
            ),
            child: Row(
              children: [
                Icon(Icons.library_books, size: 44, color: colorScheme.primary),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${widget.selectedField} Study Studio',
                        style: Theme.of(context).textTheme.headlineSmall
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Field-aware resources you can turn into subjects, tasks, and reusable prompts.',
                        style: TextStyle(color: colorScheme.onPrimaryContainer),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: categories
                  .map(
                    (category) => Padding(
                      padding: const EdgeInsets.only(right: 10),
                      child: ChoiceChip(
                        label: Text(category),
                        selected: selectedCategory == category,
                        onSelected: (_) {
                          setState(() {
                            selectedCategory = category;
                          });
                        },
                      ),
                    ),
                  )
                  .toList(),
            ),
          ),
          const SizedBox(height: 16),
          ...items.map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: InkWell(
                onTap: () => openResource(item),
                borderRadius: BorderRadius.circular(14),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: colorScheme.surface,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: colorScheme.outlineVariant),
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: colorScheme.secondaryContainer,
                        child: Icon(item.icon, color: colorScheme.secondary),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.title,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(item.description),
                          ],
                        ),
                      ),
                      const Icon(Icons.chevron_right),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ResourceItem {
  final String category;
  final String title;
  final String description;
  final IconData icon;
  final String quickTask;
  final String prompt;
  final List<String> steps;

  const _ResourceItem({
    required this.category,
    required this.title,
    required this.description,
    required this.icon,
    required this.quickTask,
    required this.prompt,
    required this.steps,
  });
}
