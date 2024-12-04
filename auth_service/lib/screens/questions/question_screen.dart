import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import './question_model.dart';
import './question_service.dart';
import './widgets/single_choice_question.dart';
import './widgets/multi_choice_question.dart';
import './widgets/likert_scale_question.dart';
import './widgets/matrix_table_question.dart';
import './widgets/dropdown_question.dart';

class QuestionScreen extends StatefulWidget {
  const QuestionScreen({Key? key}) : super(key: key);

  @override
  _QuestionScreenState createState() => _QuestionScreenState();
}

class _QuestionScreenState extends State<QuestionScreen>
  with SingleTickerProviderStateMixin {
  final QuestionService _questionService = QuestionService();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String? currentQuestionId = 'q1';
  Question? currentQuestion;
  Map<String, String> userAnswers = {};
  List<String> questionHistory = [];
  bool isLoading = true;
  bool hasError = false;

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  bool _isAnimationInitialized = false;

  @override
  void initState() {
    super.initState();

    // Initialize animation controller and fade animation
    _animationController =
        AnimationController(vsync: this, duration: const Duration(seconds: 1));
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );

    // Set animation initialized flag after the first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        _isAnimationInitialized = true;
      });
    });

    // Load the initial question
    _loadQuestion(currentQuestionId!);
  }

  // Load a question by its ID
  Future<void> _loadQuestion(String questionId) async {
    setState(() {
      isLoading = true;
      hasError = false;
    });

    try {
      final question = await _questionService.getQuestion(questionId);
      setState(() {
        currentQuestion = question;
        currentQuestionId = questionId;
        isLoading = false;
      });
      _animationController.forward(from: 0); // Trigger fade animation
    } catch (e) {
      setState(() {
        currentQuestion = null;
        currentQuestionId = null;
        isLoading = false;
        hasError = true;
      });
    }
  }

  // Save the user's answer to the current question
  Future<void> _saveAnswer(String answer) async {
    final user = _auth.currentUser;
    if (user == null) return;

    setState(() {
      userAnswers[currentQuestionId!] = answer;
    });

    await _questionService.saveUserAnswer(user.uid, currentQuestionId!, answer);
  }

  // Load the next question based on the user's answer
  Future<void> _nextQuestion() async {
    if (!questionHistory.contains(currentQuestionId!)) {
      questionHistory.add(currentQuestionId!);
    }

    final nextQuestionId =
        currentQuestion?.next?[userAnswers[currentQuestionId!] ?? ''] ?? currentQuestion?.next?['default'];

    if (nextQuestionId != null) {
      await _loadQuestion(nextQuestionId);
    } else {
      Navigator.pushReplacementNamed(context, '/end');
    }
  }

  // Load the previous question from the history
  Future<void> _previousQuestion() async {
    if (questionHistory.isEmpty) return;

    final previousQuestionId = questionHistory.removeLast();

    if (previousQuestionId != null) {
      await _loadQuestion(previousQuestionId);
    }
  }

  // Build the appropriate widget for the current question type
  Widget _buildQuestion(Question question) {
    switch (question.type) {
      case 'single_choice':
        return SingleChoiceQuestion(
          question: question,
          selectedOption: userAnswers[question.id],
          onOptionSelected: (value) => _saveAnswer(value),
        );
      case 'multi_choice':
        return MultiChoiceQuestion(
          question: question,
          selectedOptions: userAnswers[question.id]?.split(',') ?? [],
          onOptionsSelected: (options) => _saveAnswer(options.join(',')),
        );
      case 'likert_scale':
        return LikertScaleQuestion(
          question: question,
          selectedOption: userAnswers[question.id],
          onOptionSelected: (value) => _saveAnswer(value),
        );
      case 'dropdown':
        return DropdownQuestion(
          question: question,
          selectedOption: userAnswers[question.id],
          onOptionSelected: (value) => _saveAnswer(value),
        );
      case 'matrix_table':
        return MatrixTableQuestion(
          question: question,
          responses: userAnswers[question.id] != null
              ? Map.fromEntries(
                  (userAnswers[question.id]!.split(';')).map((entry) {
                    final parts = entry.split(':');
                    return MapEntry(parts[0], parts[1]);
                  }),
                )
              : {},
          onResponsesSubmitted: (responses) {
            final formattedResponse = responses.entries
                .map((entry) => '${entry.key}:${entry.value}')
                .join(';');
            _saveAnswer(formattedResponse);
          },
        );
      default:
        return const Text('Type de question non pris en charge');
    }
  }

  // Check if the current question is the last one
  bool isLastQuestion(Question? question) {
    if (question == null) return false;
    return question.next != null && question.next!['default'] == "end";
  }

  @override
  Widget build(BuildContext context) {
    if (!_isAnimationInitialized) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Interactive Questionnaire',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.lightBlueAccent,
        elevation: 10,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(30),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Déconnexion',
            onPressed: () async {
              await _auth.signOut();
              Navigator.pushReplacementNamed(context, '/login');
            },
          ),
        ],
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: Container(
          decoration: const BoxDecoration(
            gradient: RadialGradient(
              colors: [Colors.white, Colors.lightBlueAccent],
              center: Alignment.topCenter,
              radius: 2,
            ),
          ),
          child: isLoading
              ? const Center(
                  child: CircularProgressIndicator(
                    color: Colors.lightBlue,
                  ),
                )
              : hasError
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            'Erreur : Impossible de charger la question.',
                            style: TextStyle(color: Colors.red, fontSize: 18),
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.lightBlueAccent,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            onPressed: () => _loadQuestion(currentQuestionId ?? 'q1'),
                            child: const Text('Réessayer'),
                          ),
                        ],
                      ),
                    )
                  : Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Card(
                        elevation: 10,
                        shadowColor: Colors.lightBlueAccent.withOpacity(0.5),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Text(
                                currentQuestion!.text,
                                style: const TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.lightBlue,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 16),
                              _buildQuestion(currentQuestion!),
                              const SizedBox(height: 24),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.lightBlueAccent,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(15),
                                      ),
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 20, vertical: 12),
                                    ),
                                    onPressed: questionHistory.isEmpty
                                        ? null
                                        : _previousQuestion,
                                    child: const Text(
                                      'Précédent',
                                      style: TextStyle(fontSize: 16),
                                    ),
                                  ),
                                  ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.lightBlueAccent,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(15),
                                      ),
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 20, vertical: 12),
                                    ),
                                    onPressed: () {
                                      if (isLastQuestion(currentQuestion)) {
                                        Navigator.pushReplacementNamed(
                                          context,
                                          '/companies',
                                          arguments: userAnswers,
                                        );
                                      } else {
                                        _nextQuestion();
                                      }
                                    },
                                    child: Text(
                                      isLastQuestion(currentQuestion)
                                          ? 'Voir les recommandations'
                                          : 'Suivant',
                                      style: const TextStyle(fontSize: 16),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }
}
