import 'package:flutter_test/flutter_test.dart';
import 'package:fusion_charts_flutter/src/core/enums/axis_range_padding.dart';
import 'package:fusion_charts_flutter/src/core/enums/fusion_data_label_display.dart';
import 'package:fusion_charts_flutter/src/core/enums/fusion_dismiss_strategy.dart';
import 'package:fusion_charts_flutter/src/core/enums/fusion_pan_edge_behavior.dart';
import 'package:fusion_charts_flutter/src/core/enums/fusion_pan_mode.dart';
import 'package:fusion_charts_flutter/src/core/enums/fusion_tooltip_activation_mode.dart';
import 'package:fusion_charts_flutter/src/core/enums/fusion_tooltip_position.dart';
import 'package:fusion_charts_flutter/src/core/enums/fusion_tooltip_trackball_mode.dart';
import 'package:fusion_charts_flutter/src/core/enums/fusion_zoom_mode.dart';
import 'package:fusion_charts_flutter/src/core/enums/interaction_anchor_mode.dart';
import 'package:fusion_charts_flutter/src/core/enums/label_alignment.dart';
import 'package:fusion_charts_flutter/src/core/enums/marker_shape.dart';

void main() {
  // ===========================================================================
  // FUSION PAN MODE
  // ===========================================================================
  group('FusionPanMode', () {
    test('has all expected values', () {
      expect(FusionPanMode.values, hasLength(4));
      expect(FusionPanMode.values, contains(FusionPanMode.x));
      expect(FusionPanMode.values, contains(FusionPanMode.y));
      expect(FusionPanMode.values, contains(FusionPanMode.both));
      expect(FusionPanMode.values, contains(FusionPanMode.none));
    });
  });

  // ===========================================================================
  // FUSION ZOOM MODE
  // ===========================================================================
  group('FusionZoomMode', () {
    test('has all expected values', () {
      expect(FusionZoomMode.values, hasLength(4));
      expect(FusionZoomMode.values, contains(FusionZoomMode.x));
      expect(FusionZoomMode.values, contains(FusionZoomMode.y));
      expect(FusionZoomMode.values, contains(FusionZoomMode.both));
      expect(FusionZoomMode.values, contains(FusionZoomMode.none));
    });
  });

  // ===========================================================================
  // FUSION PAN EDGE BEHAVIOR
  // ===========================================================================
  group('FusionPanEdgeBehavior', () {
    test('has all expected values', () {
      expect(FusionPanEdgeBehavior.values, hasLength(3));
      expect(
        FusionPanEdgeBehavior.values,
        contains(FusionPanEdgeBehavior.clamp),
      );
      expect(
        FusionPanEdgeBehavior.values,
        contains(FusionPanEdgeBehavior.bounce),
      );
      expect(
        FusionPanEdgeBehavior.values,
        contains(FusionPanEdgeBehavior.free),
      );
    });
  });

  // ===========================================================================
  // FUSION TOOLTIP ACTIVATION MODE
  // ===========================================================================
  group('FusionTooltipActivationMode', () {
    test('has all expected values', () {
      expect(FusionTooltipActivationMode.values, hasLength(6));
      expect(
        FusionTooltipActivationMode.values,
        contains(FusionTooltipActivationMode.singleTap),
      );
      expect(
        FusionTooltipActivationMode.values,
        contains(FusionTooltipActivationMode.longPress),
      );
      expect(
        FusionTooltipActivationMode.values,
        contains(FusionTooltipActivationMode.doubleTap),
      );
      expect(
        FusionTooltipActivationMode.values,
        contains(FusionTooltipActivationMode.hover),
      );
      expect(
        FusionTooltipActivationMode.values,
        contains(FusionTooltipActivationMode.auto),
      );
      expect(
        FusionTooltipActivationMode.values,
        contains(FusionTooltipActivationMode.none),
      );
    });
  });

  // ===========================================================================
  // FUSION TOOLTIP POSITION
  // ===========================================================================
  group('FusionTooltipPosition', () {
    test('has all expected values', () {
      expect(FusionTooltipPosition.values, hasLength(3));
      expect(
        FusionTooltipPosition.values,
        contains(FusionTooltipPosition.floating),
      );
      expect(FusionTooltipPosition.values, contains(FusionTooltipPosition.top));
      expect(
        FusionTooltipPosition.values,
        contains(FusionTooltipPosition.bottom),
      );
    });
  });

  // ===========================================================================
  // FUSION TOOLTIP TRACKBALL MODE
  // ===========================================================================
  group('FusionTooltipTrackballMode', () {
    test('has all expected values', () {
      expect(FusionTooltipTrackballMode.values, hasLength(6));
      expect(
        FusionTooltipTrackballMode.values,
        contains(FusionTooltipTrackballMode.none),
      );
      expect(
        FusionTooltipTrackballMode.values,
        contains(FusionTooltipTrackballMode.follow),
      );
      expect(
        FusionTooltipTrackballMode.values,
        contains(FusionTooltipTrackballMode.snapToX),
      );
      expect(
        FusionTooltipTrackballMode.values,
        contains(FusionTooltipTrackballMode.snap),
      );
      expect(
        FusionTooltipTrackballMode.values,
        contains(FusionTooltipTrackballMode.magnetic),
      );
      expect(
        FusionTooltipTrackballMode.values,
        contains(FusionTooltipTrackballMode.snapToY),
      );
    });
  });

  // ===========================================================================
  // FUSION DISMISS STRATEGY
  // ===========================================================================
  group('FusionDismissStrategy', () {
    test('has all expected values', () {
      expect(FusionDismissStrategy.values, hasLength(5));
      expect(
        FusionDismissStrategy.values,
        contains(FusionDismissStrategy.onRelease),
      );
      expect(
        FusionDismissStrategy.values,
        contains(FusionDismissStrategy.onTimer),
      );
      expect(
        FusionDismissStrategy.values,
        contains(FusionDismissStrategy.onReleaseDelayed),
      );
      expect(
        FusionDismissStrategy.values,
        contains(FusionDismissStrategy.never),
      );
      expect(
        FusionDismissStrategy.values,
        contains(FusionDismissStrategy.smart),
      );
    });
  });

  // ===========================================================================
  // INTERACTION ANCHOR MODE
  // ===========================================================================
  group('InteractionAnchorMode', () {
    test('has all expected values', () {
      expect(InteractionAnchorMode.values, hasLength(2));
      expect(
        InteractionAnchorMode.values,
        contains(InteractionAnchorMode.screenPosition),
      );
      expect(
        InteractionAnchorMode.values,
        contains(InteractionAnchorMode.dataPoint),
      );
    });
  });

  // ===========================================================================
  // AXIS RANGE PADDING
  // ===========================================================================
  group('AxisRangePadding', () {
    test('has all expected values', () {
      expect(AxisRangePadding.values, hasLength(5));
      expect(AxisRangePadding.values, contains(AxisRangePadding.none));
      expect(AxisRangePadding.values, contains(AxisRangePadding.normal));
      expect(AxisRangePadding.values, contains(AxisRangePadding.round));
      expect(AxisRangePadding.values, contains(AxisRangePadding.additional));
      expect(AxisRangePadding.values, contains(AxisRangePadding.auto));
    });
  });

  // ===========================================================================
  // LABEL ALIGNMENT
  // ===========================================================================
  group('LabelAlignment', () {
    test('has all expected values', () {
      expect(LabelAlignment.values, hasLength(3));
      expect(LabelAlignment.values, contains(LabelAlignment.start));
      expect(LabelAlignment.values, contains(LabelAlignment.center));
      expect(LabelAlignment.values, contains(LabelAlignment.end));
    });
  });

  // ===========================================================================
  // MARKER SHAPE
  // ===========================================================================
  group('MarkerShape', () {
    test('has all expected values', () {
      expect(MarkerShape.values, hasLength(6));
      expect(MarkerShape.values, contains(MarkerShape.circle));
      expect(MarkerShape.values, contains(MarkerShape.square));
      expect(MarkerShape.values, contains(MarkerShape.diamond));
      expect(MarkerShape.values, contains(MarkerShape.triangle));
      expect(MarkerShape.values, contains(MarkerShape.cross));
      expect(MarkerShape.values, contains(MarkerShape.x));
    });
  });

  // ===========================================================================
  // FUSION DATA LABEL DISPLAY
  // ===========================================================================
  group('FusionDataLabelDisplay', () {
    test('has all expected values', () {
      expect(FusionDataLabelDisplay.values, hasLength(6));
      expect(
        FusionDataLabelDisplay.values,
        contains(FusionDataLabelDisplay.all),
      );
      expect(
        FusionDataLabelDisplay.values,
        contains(FusionDataLabelDisplay.none),
      );
      expect(
        FusionDataLabelDisplay.values,
        contains(FusionDataLabelDisplay.maxOnly),
      );
      expect(
        FusionDataLabelDisplay.values,
        contains(FusionDataLabelDisplay.minOnly),
      );
      expect(
        FusionDataLabelDisplay.values,
        contains(FusionDataLabelDisplay.maxAndMin),
      );
      expect(
        FusionDataLabelDisplay.values,
        contains(FusionDataLabelDisplay.firstAndLast),
      );
    });
  });
}
