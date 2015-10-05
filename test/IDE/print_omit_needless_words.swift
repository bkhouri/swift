// RUN: rm -rf %t
// RUN: mkdir -p %t

// REQUIRES: objc_interop

// RUN: %target-swift-frontend(mock-sdk: %clang-importer-sdk -I %t) -emit-module -o %t -enable-omit-needless-words %S/../Inputs/clang-importer-sdk/swift-modules/ObjectiveC.swift
// RUN: %target-swift-frontend(mock-sdk: %clang-importer-sdk -I %t) -emit-module -o %t -enable-omit-needless-words %S/../Inputs/clang-importer-sdk/swift-modules/CoreGraphics.swift
// RUN: %target-swift-frontend(mock-sdk: %clang-importer-sdk -I %t) -emit-module -o %t -enable-omit-needless-words %S/../Inputs/clang-importer-sdk/swift-modules/Foundation.swift

// RUN: %target-swift-frontend(mock-sdk: %clang-importer-sdk -I %t) -emit-module -o %t -enable-omit-needless-words %S/../Inputs/clang-importer-sdk/swift-modules/AppKit.swift

// RUN: %target-swift-ide-test(mock-sdk: -sdk %S/../Inputs/clang-importer-sdk -I %t) -print-module -source-filename %s -module-to-print=ObjectiveC -function-definitions=false -prefer-type-repr=true -enable-omit-needless-words -enable-infer-default-arguments > %t.ObjectiveC.txt
// RUN: FileCheck %s -check-prefix=CHECK-OBJECTIVEC -strict-whitespace < %t.ObjectiveC.txt

// RUN: %target-swift-ide-test(mock-sdk: -sdk %S/../Inputs/clang-importer-sdk -I %t) -print-module -source-filename %s -module-to-print=Foundation -function-definitions=false -prefer-type-repr=true -enable-omit-needless-words -skip-parameter-names -enable-infer-default-arguments > %t.Foundation.txt
// RUN: FileCheck %s -check-prefix=CHECK-FOUNDATION -strict-whitespace < %t.Foundation.txt

// RUN: %target-swift-ide-test(mock-sdk: -sdk %S/../Inputs/clang-importer-sdk -I %t) -print-module -source-filename %s -module-to-print=AppKit -function-definitions=false -prefer-type-repr=true -enable-omit-needless-words -skip-parameter-names -enable-infer-default-arguments > %t.AppKit.txt
// RUN: FileCheck %s -check-prefix=CHECK-APPKIT -strict-whitespace < %t.AppKit.txt

// RUN: %target-swift-ide-test(mock-sdk: -sdk %S/../Inputs/clang-importer-sdk -I %t -I %S/../ClangModules/Inputs/custom-modules) -print-module -source-filename %s -module-to-print=CoreCooling -function-definitions=false -prefer-type-repr=true -enable-omit-needless-words -skip-parameter-names -enable-infer-default-arguments > %t.CoreCooling.txt
// RUN: FileCheck %s -check-prefix=CHECK-CORECOOLING -strict-whitespace < %t.CoreCooling.txt

// Note: SEL -> "Selector"
// CHECK-FOUNDATION: func makeObjectsPerform(_: Selector)

// Note: "with" parameters.
// CHECK-FOUNDATION: func makeObjectsPerform(_: Selector, with: AnyObject?)

// Note: "with" parameters drop the "with".
// CHECK-FOUNDATION: func makeObjectsPerform(_: Selector, with: AnyObject?, with: AnyObject?)

// Note: id -> "Object".
// CHECK-FOUNDATION: func indexOf(_: AnyObject) -> Int

// Note: Class -> "Class"
// CHECK-OBJECTIVEC: func isKindOf(aClass: AnyClass) -> Bool

// Note: Pointer-to-struct name matching; "with" splits the first piece.
// CHECK-FOUNDATION: func copy(with _: NSZone = nil) -> AnyObject!

// Note: Objective-C type parameter names.
// CHECK-FOUNDATION: func objectFor(_: NSCopying) -> AnyObject?
// CHECK-FOUNDATION: func removeObjectFor(_: NSCopying)

// Note: Allow argument labels that are keywords.
// CHECK-FOUNDATION: func setObject(_: AnyObject, `for`: NSCopying)

// Note: Don't drop the name of the first parameter in an initializer entirely.
// CHECK-FOUNDATION: init(array: [AnyObject])

// Note: struct name matching; don't drop "With".
// CHECK-FOUNDATION: class func withRange(_: NSRange) -> NSValue

// Note: built-in types.
// CHECK-FOUNDATION: func add(_: Double) -> NSNumber

// Note: built-in types.
// CHECK-FOUNDATION: func add(_: Bool) -> NSNumber

// Note: builtin-types.
// CHECK-FOUNDATION: func add(_: UInt16) -> NSNumber

// Note: builtin-types.
// CHECK-FOUNDATION: func add(_: Int32) -> NSNumber

// Note: Typedefs with a "_t" suffix".
// CHECK-FOUNDATION: func subtract(_: Int32) -> NSNumber

// Note: multi-word enum name matching; "with" splits the first piece.
// CHECK-FOUNDATION: func someMethod(with _: NSDeprecatedOptions = [])

// Note: class name matching; don't drop "With".
// CHECK-FOUNDATION: class func withString(_: String!) -> Self!

// Note: Make sure NSURL works in various places
// CHECK-FOUNDATION: open(_: NSURL!, completionHandler: ((Bool) -> Void)!)

// Note: property name stripping property type.
// CHECK-FOUNDATION: var uppercase: String

// Note: don't map base name down to a keyword.
// CHECK-FOUNDATION: func doSelector(_: Selector)

// Note: Strip names preceded by a gerund.
// CHECK-FOUNDATION: func startSquashing(_: Bee)
// CHECK-FOUNDATION: func startSoothing(_: Bee)
// CHECK-FOUNDATION: func startShopping(_: Bee)

// Note: Removing plural forms when working with collections
// CHECK-FOUNDATION: func add(_: [AnyObject])

// Note: Int and Index match.
// CHECK-FOUNDATION: func sliceFrom(_: Int, to: Int) -> String

// Note: <context type>By<gerund> --> <gerund>.
// CHECK-FOUNDATION: func appending(_: String) -> String

// Note: <context type>By<gerund> --> <gerund>.
// CHECK-FOUNDATION: func withString(_: String) -> String

// Note: Not splitting on "With".
// CHECK-FOUNDATION: func URLWithAddedString(_: String) -> NSURL?

// Note: CalendarUnits is not a set of "Options".
// CHECK-FOUNDATION: class func forCalendarUnits(_: NSCalendarUnit) -> String!

// Note: <property type>By<gerund> --> <gerund>.
// CHECK-FOUNDATION: var deletingLastPathComponent: NSURL? { get }

// Note: <property type><preposition> --> <preposition>.
// CHECK-FOUNDATION: var withHTTPS: NSURL { get }

// Note: usingBlock -> body
// CHECK-FOUNDATION: func enumerateObjectsUsing(_: ((AnyObject!, Int, UnsafeMutablePointer<ObjCBool>) -> Void)!)
// CHECK-FOUNDATION: func enumerateObjects(with _: NSEnumerationOptions = [], using: ((AnyObject!, Int, UnsafeMutablePointer<ObjCBool>) -> Void)!)

// Note: WithBlock -> body, nullable closures default to nil.
// CHECK-FOUNDATION: func enumerateObjectsRandomly(with _: ((AnyObject!, Int, UnsafeMutablePointer<ObjCBool>) -> Void)? = nil)

// Note: id<Proto> treated as "Proto".
// CHECK-FOUNDATION: func doSomethingWith(_: NSCopying)

// Note: NSObject<Proto> treated as "Proto".
// CHECK-FOUNDATION: func doSomethingElseWith(_: protocol<NSCopying, NSObjectProtocol>)

// Note: Function type -> "Function".
// CHECK-FOUNDATION: func sortUsing(_: @convention(c) (AnyObject, AnyObject) -> Int)

// Note: Plural: NSArray without type arguments -> "Objects".
// CHECK-FOUNDATION: func remove(_: [AnyObject])

// Note: Skipping "Type" suffix.
// CHECK-FOUNDATION: func doSomethingWith(_: NSUnderlyingType)

// Don't introduce default arguments for lone parameters to setters.
// CHECK-FOUNDATION: func setDefaultEnumerationOptions(_: NSEnumerationOptions)

// Introducing argument labels without pruning.
// CHECK-FOUNDATION: func normalizingXMLPreservingComments(preserve _: Bool)

// Note: class method name stripping context type.
// CHECK-APPKIT: class func red() -> NSColor

// Note: instance method name stripping context type.
// CHECK-APPKIT: func same() -> Self

// Note: Unsafe(Mutable)Pointers don't get defaulted to 'nil'
// CHECK-APPKIT: func getRGBAComponents(_: UnsafeMutablePointer<Int8>)

// Note: Skipping over "3D"
// CHECK-APPKIT: func drawInAirAt(_: Point3D)

// Note: with<something> -> <something>
// CHECK-APPKIT: func drawAt(_: Point3D, attributes: [String : AnyObject]?)

// Note: Don't strip names that aren't preceded by a verb or preposition.
// CHECK-APPKIT: func setTextColor(_: NSColor?)

// Note: Splitting with default arguments.
// CHECK-APPKIT: func drawIn(_: NSView?)

// Note: Skipping over "Ref"
// CHECK-CORECOOLING: func replace(_: CCPowerSupply!)

// Make sure we're removing redundant context type info at both the
// beginning and the end.
// CHECK-APPKIT: func reversing() -> NSBezierPath

// Make sure we're dealing with 'instancetype' properly.
// CHECK-APPKIT: func inventing() -> Self

// Make sure we're removing redundant context type info at both the
// beginning and the end of a property.
// CHECK-APPKIT: var flattening: NSBezierPath { get }

// Introducing argument labels and pruning the base name.
// CHECK-APPKIT: func dismiss(animated _: Bool)

// Introducing argument labels and pruning the base name with a preposition.
// CHECK-APPKIT: func shouldCollapseAutoExpandedItems(forDeposited _: Bool) -> Bool

// Introducing argument labels and pruning the base name.
// CHECK-APPKIT: func rectForCancelButton(whenCentered _: Bool)

// Introducing argument labels and pruning the base name by splitting
// at "and".
// CHECK-APPKIT: func openUntitledDocument(display _: Bool)

