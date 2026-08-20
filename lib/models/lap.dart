/// A single lap recorded during an active tracking session.
///
/// Stores the TOTAL elapsed time at the moment Lap was pressed (not
/// the split since the previous lap), so lap times read as a
/// running total — consistent with a typical stopwatch app.
class Lap {
  final int number;
  final Duration elapsedAtLap;

  const Lap({required this.number, required this.elapsedAtLap});
}