export interface UnderstandingAssociatedTechniqueEntry {
  id?: string;
  title?: string;
  /** Combines with `id` to specify text before the linked technique title */
  prefix?: string;
  /** Combines with `id` to specify text after the linked technique title */
  suffix?: string;
}

interface UnderstandingAssociatedTechniqueUsingMixin {
  skipUsingPhrase?: boolean;
  using: UnderstandingAssociatedTechniqueArray;
  usingConjunction?: string;
  usingPrefix?: string;
  usingQuantity?: string;
}

interface UnderstandingAssociatedTechniqueEntryWithUsing
  extends UnderstandingAssociatedTechniqueEntry,
    UnderstandingAssociatedTechniqueUsingMixin {}

interface UnderstandingAssociatedTechniqueConjunction {
  and: Array<string | UnderstandingAssociatedTechniqueEntry>;
  andConjunction?: string;
}

interface UnderstandingAssociatedTechniqueConjunctionWithUsing
  extends UnderstandingAssociatedTechniqueConjunction,
    UnderstandingAssociatedTechniqueUsingMixin {}

/** Represents either type of associated technique entry that contains `using` */
export type UnderstandingAssociatedTechniqueParent =
  | UnderstandingAssociatedTechniqueEntryWithUsing
  | UnderstandingAssociatedTechniqueConjunctionWithUsing;

type UnderstandingAssociatedTechniqueArrayElement =
  | string
  | UnderstandingAssociatedTechniqueEntry
  | UnderstandingAssociatedTechniqueConjunction
  | UnderstandingAssociatedTechniqueParent;

/** Array of shorthand strings or objects defining associated techniques */
export type UnderstandingAssociatedTechniqueArray = UnderstandingAssociatedTechniqueArrayElement[];

/** An associated technique that has already been run through expandTechniqueToObject */
export type ResolvedUnderstandingAssociatedTechnique = Exclude<
  UnderstandingAssociatedTechniqueArray[number],
  string
>;

interface UnderstandingAssociatedTechniqueSectionBase {
  title: string;
  note?: string;
}
interface UnderstandingAssociatedTechniqueSectionWithoutGroups
  extends UnderstandingAssociatedTechniqueSectionBase {
  techniques: UnderstandingAssociatedTechniqueArray;
  groups?: never; // Needed to form discriminated union between with/without
}
export interface UnderstandingAssociatedTechniqueGroup {
  id: string;
  title: string;
  techniques: UnderstandingAssociatedTechniqueArray;
}
interface UnderstandingAssociatedTechniqueSectionWithGroups
  extends UnderstandingAssociatedTechniqueSectionBase {
  groups: UnderstandingAssociatedTechniqueGroup[];
  // Restrict techniques to types without `using` when paired with `groups`
  techniques: Array<
    string | UnderstandingAssociatedTechniqueEntry | UnderstandingAssociatedTechniqueConjunction
  >;
}

/** A top-level section (most commonly used to define multiple situations) */
export type UnderstandingAssociatedTechniqueSection =
  | UnderstandingAssociatedTechniqueSectionWithoutGroups
  | UnderstandingAssociatedTechniqueSectionWithGroups;

/** Object defining various types of techniques for a success criterion */
interface UnderstandingAssociatedTechniques {
  advisory?: UnderstandingAssociatedTechniqueArray;
  failure?: UnderstandingAssociatedTechniqueArray;
  sufficient?: UnderstandingAssociatedTechniqueSection[] | UnderstandingAssociatedTechniqueArray;
  sufficientIntro?: string;
  sufficientNote?: string;
}

export type UnderstandingAssociatedTechniquesMap = Record<
  string,
  UnderstandingAssociatedTechniques
>;
