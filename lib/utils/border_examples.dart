import 'package:flutter/material.dart';
import 'package:reimbursement_box/utils/border_styles.dart';
import 'package:reimbursement_box/widgets/gradient_card.dart';
import 'package:reimbursement_box/widgets/gradient_button.dart';
import 'package:reimbursement_box/widgets/bordered_container.dart';
import 'package:reimbursement_box/widgets/bordered_input.dart';

/// Utility class demonstrating how to use the border components
class BorderExamples {
  /// Example of using GradientCard with a solid border
  static Widget gradientCardWithBorder(BuildContext context) {
    return GradientCard(
      useSolidBorder: true,
      borderColor: Theme.of(context).colorScheme.primary,
      child: Text('Card with solid border'),
    );
  }
  
  /// Example of using GradientButton with border
  static Widget gradientButtonWithBorder(BuildContext context) {
    return GradientButton(
      text: 'Button with border',
      useBorder: true,
      borderColor: Colors.white.withOpacity(0.5),
      onPressed: () {},
    );
  }
  
  /// Example of using BorderedContainer
  static Widget borderedContainer(BuildContext context) {
    return BorderedContainer(
      borderColor: Theme.of(context).colorScheme.secondary,
      borderWidth: 2.0,
      child: Text('Custom bordered container'),
    );
  }
  
  /// Example of using BorderedInput
  static Widget borderedInput(BuildContext context) {
    return BorderedInput(
      hintText: 'Input with border',
      borderColor: Theme.of(context).colorScheme.primary.withOpacity(0.5),
    );
  }
  
  /// Examples of different border styles
  static List<Border> getBorderExamples(BuildContext context) {
    return [
      // Standard themed border
      BorderStyles.getThemedBorder(context),
      
      // Colored border
      BorderStyles.getColoredBorder(Colors.blue),
      
      // Thicker border
      BorderStyles.getColoredBorder(Colors.red, width: 3.0),
      
      // Semi-transparent border
      BorderStyles.getColoredBorder(Colors.green.withOpacity(0.5)),
    ];
  }
}

/// Widget demonstrating all border examples together
class BorderExamplesView extends StatelessWidget {
  const BorderExamplesView({Key? key}) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(
          'Border Examples',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 16),
        
        BorderExamples.gradientCardWithBorder(context),
        const SizedBox(height: 16),
        
        BorderExamples.gradientButtonWithBorder(context),
        const SizedBox(height: 16),
        
        BorderExamples.borderedContainer(context),
        const SizedBox(height: 16),
        
        BorderExamples.borderedInput(context),
        const SizedBox(height: 32),
        
        Text(
          'Border Style Examples',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 16),
        
        ...BorderExamples.getBorderExamples(context).map((border) {
          return Container(
            height: 80,
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(BorderStyles.borderRadius),
              border: border,
            ),
            child: Center(
              child: Text('Border Example'),
            ),
          );
        }).toList(),
      ],
    );
  }
} 