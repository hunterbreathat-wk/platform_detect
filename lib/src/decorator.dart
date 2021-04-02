// Copyright 2017 Workiva Inc.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
import 'dart:html';

import 'package:meta/meta.dart';
import 'package:platform_detect/platform_detect.dart';
import 'package:platform_detect/src/support.dart';

/// The CSS class that will be used to indicate that [decorateRootNodeWithPlatformClasses]
/// has already been invoked for a given root node.
@visibleForTesting
const String decorationCompleteClassName = 'pd--decorated';

/// The CSS class that will be used to represent the current [browser].
@visibleForTesting
final String browserClassName =
    browser.className ?? nameToClassName(browser.name);

/// The CSS class that will be used to represent the current [operatingSystem].
@visibleForTesting
final String osClassName = nameToClassName(operatingSystem.name);

/// The string that will be prepended to the CSS class generated by [getPlatformClasses]
/// for [browserClassName].
@visibleForTesting
const String browserClassPrefix = 'ua-';

/// The string that will be prepended to the CSS class generated by [getPlatformClasses]
/// for [osClassName].
@visibleForTesting
const String osClassPrefix = 'os-';

/// The string that will be prepended to the CSS class generated by [getPlatformClasses]
/// for [osClassName].
@visibleForTesting
const String versionRangeClassPrefix = 'lt-';

/// The string that will be prepended to the CSS class generated by [getPlatformClasses]
/// for [Feature.name] if [Feature.isSupported] is `false`.
@visibleForTesting
const String featureSupportNegationClassPrefix = 'no-';

/// The first major release after the current one.
@visibleForTesting
final int nextVersion = browser.version.major + 1;

/// The number of major releases above [nextVersion]
/// that [getBrowserVersionClasses] should produce CSS classes for.
@visibleForTesting
const int decoratedNextVersionCount = 2;

/// Utility fn that returns the CSS classes that are analogous to the [browser.version].
@visibleForTesting
String getBrowserVersionClasses() {
  var majorVersion = browser.version.major;
  var classes = [
    browserClassPrefix + browserClassName + majorVersion.toString()
  ];

  for (var i = nextVersion; i < nextVersion + decoratedNextVersionCount; i++) {
    classes
        .add('$browserClassPrefix$versionRangeClassPrefix$browserClassName$i');
  }

  return listToClassNameString(classes);
}

/// Utility fn that returns the CSS classes that are analogous to the provided list of [features].
@visibleForTesting
String getFeatureSupportClasses(Iterable<Feature> features) {
  var classes = features.map((feature) => feature.isSupported
      ? feature.name
      : '$featureSupportNegationClassPrefix${feature.name}');

  return listToClassNameString(classes.toList());
}

/// Utility fn that takes a list of [classes] and returns a space-separated string for
/// use within the `class` attribute on the `<html>` element that gets injected by
/// [decorateRootNodeWithPlatformClasses].
@visibleForTesting
String listToClassNameString(List<String> classes) =>
    classes.where((classStr) => classStr.isNotEmpty).join(' ');

/// Convert white-space within the given [name] to dashes, and convert it to lowercase
/// for standardized CSS class formatting.
@visibleForTesting
String nameToClassName(String name) {
  return name.replaceAll(' ', '-').toLowerCase();
}

/// Whether the given [rootNode] has already had it's CSS classes set via [decorateRootNodeWithPlatformClasses].
bool nodeHasBeenDecorated(Element rootNode) =>
    rootNode.classes.contains(decorationCompleteClassName);

/// Generates CSS classes based on the current [browser], [operatingSystem] and optionally,
/// [features] that your app may need conditional styling for in addition to the
/// [defaultFeatureCssClassDecorators] that will have CSS classes present by default.
///
/// If you do not want [defaultFeatureCssClassDecorators] to be used,
/// set [includeDefaults] to `false`.
String getPlatformClasses(
    {List<Feature>? features,
    bool includeDefaults = true,
    List<String> existingClasses = const []}) {
  var allFeatures = Set<Feature>.from(features ?? []);

  if (includeDefaults) allFeatures.addAll(defaultFeatureCssClassDecorators);

  var classes = <String>[]
    ..addAll(existingClasses)
    ..add(browserClassPrefix + browserClassName)
    ..add(getBrowserVersionClasses())
    ..add(osClassPrefix + osClassName)
    ..add(getFeatureSupportClasses(allFeatures))
    ..add(decorationCompleteClassName);

  return listToClassNameString(classes);
}

/// Appends CSS classes generated by [getPlatformClasses] to the specified [rootNode].
///
/// If you do not want [defaultFeatureCssClassDecorators] to be used,
/// set [includeDefaults] to `false`.
///
/// By default, [rootNode] is [document.documentElement].
void decorateRootNodeWithPlatformClasses(
    {List<Feature>? features,
    bool includeDefaults = true,
    Element? rootNode,
    callback()?}) {
  rootNode ??= document.documentElement;

  if (rootNode != null && !nodeHasBeenDecorated(rootNode)) {
    var existingClasses = rootNode.classes.toList();

    rootNode.className = getPlatformClasses(
        features: features,
        includeDefaults: includeDefaults,
        existingClasses: existingClasses);

    if (callback != null) callback();
  }
}
