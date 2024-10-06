import ExpoModulesCore
import HealthKit

public class AppleHealthKitExportModule: Module {
  public func definition() -> ModuleDefinition {
    Name("AppleHealthKitExport")

    Function("requestAuthorization") { (identifiers: [String]) -> Promise in
      Promise { promise in
        self.requestAuthorization(for: identifiers) { success, error in
          if let error = error {
            promise.reject(error)
          } else {
            promise.resolve(success)
          }
        }
      }
    }

    Function("exportHealthData") { (params: [String: Any]) -> Promise in
      Promise { promise in
        guard let identifiers = params["identifiers"] as? [[String: String]],
          let startDate = (params["startDate"] as? Double).flatMap({
            Date(timeIntervalSince1970: $0)
          }),
          let endDate = (params["endDate"] as? Double).flatMap({ Date(timeIntervalSince1970: $0) })
        else {
          promise.reject(
            NSError(
              domain: "ExpoHealthKit", code: 1,
              userInfo: [NSLocalizedDescriptionKey: "Invalid parameters"]))
          return
        }

        self.exportHealthData(for: identifiers, startDate: startDate, endDate: endDate) {
          data, error in
          if let error = error {
            promise.reject(error)
          } else {
            promise.resolve(data)
          }
        }
      }
    }
  }

  private let healthStore = HKHealthStore()

  private func requestAuthorization(
    for identifiers: [String], completion: @escaping (Bool, Error?) -> Void
  ) {
    guard HKHealthStore.isHealthDataAvailable() else {
      completion(
        false,
        NSError(
          domain: "ExpoHealthKit", code: 0,
          userInfo: [NSLocalizedDescriptionKey: "HealthKit is not available on this device"]))
      return
    }

    let typesToRead: Set<HKObjectType> = Set(
      identifiers.compactMap { identifier in
        return HKObjectType.quantityType(
          forIdentifier: HKQuantityTypeIdentifier(rawValue: identifier))
      })

    healthStore.requestAuthorization(toShare: nil, read: typesToRead, completion: completion)
  }

  private func exportHealthData(
    for identifiers: [[String: String]], startDate: Date, endDate: Date,
    completion: @escaping ([String: Any]?, Error?) -> Void
  ) {
    let predicate = HKQuery.predicateForSamples(
      withStart: startDate, end: endDate, options: .strictStartDate)

    var results: [String: [[String: Any]]] = [:]
    var errors: [String] = []
    let group = DispatchGroup()

    for identifier in identifiers {
      guard let typeIdentifier = identifier["identifier"] else {
        errors.append("Missing identifier in \(identifier)")
        continue
      }

      let unitString = identifier["unit"] ?? ""

      guard
        let quantityType = HKObjectType.quantityType(
          forIdentifier: HKQuantityTypeIdentifier(rawValue: typeIdentifier))
      else {
        errors.append("Invalid identifier: \(typeIdentifier)")
        continue
      }

      let unit: HKUnit
      if unitString.isEmpty {
        unit = self.defaultUnit(for: typeIdentifier)
      } else if let customUnit = HKUnit(from: unitString) {
        unit = customUnit
      } else {
        errors.append("Invalid unit '\(unitString)' for \(typeIdentifier). Using default unit.")
        unit = self.defaultUnit(for: typeIdentifier)
      }

      group.enter()
      let query = HKSampleQuery(
        sampleType: quantityType, predicate: predicate, limit: HKObjectQueryNoLimit,
        sortDescriptors: nil
      ) { (query, samples, error) in
        defer { group.leave() }

        if let error = error {
          errors.append("Error querying \(typeIdentifier): \(error.localizedDescription)")
          return
        }

        guard let samples = samples as? [HKQuantitySample] else {
          errors.append("No data for \(typeIdentifier)")
          return
        }

        let data = samples.map { sample -> [String: Any] in
          let value = sample.quantity.doubleValue(for: unit)
          return [
            "date": sample.startDate.timeIntervalSince1970,
            "value": value,
          ]
        }

        results[typeIdentifier] = data
      }

      healthStore.execute(query)
    }

    group.notify(queue: .main) {
      completion(["data": results, "errors": errors], nil)
    }
  }

  private func defaultUnit(for identifier: String) -> HKUnit {
    switch identifier {
    case HKQuantityTypeIdentifier.stepCount.rawValue:
      return HKUnit.count()
    case HKQuantityTypeIdentifier.heartRate.rawValue:
      return HKUnit.count().unitDivided(by: .minute())
    case HKQuantityTypeIdentifier.activeEnergyBurned.rawValue,
      HKQuantityTypeIdentifier.basalEnergyBurned.rawValue,
      HKQuantityTypeIdentifier.physicalEffort.rawValue:
      return HKUnit.kilocalorie()
    case HKQuantityTypeIdentifier.bodyMass.rawValue:
      return HKUnit.gramUnit(with: .kilo)
    case HKQuantityTypeIdentifier.height.rawValue:
      return HKUnit.meter()
    case HKQuantityTypeIdentifier.bodyTemperature.rawValue:
      return HKUnit.degreeCelsius()
    case HKQuantityTypeIdentifier.bloodGlucose.rawValue:
      return HKUnit.milligramsPerDeciliter()
    case HKQuantityTypeIdentifier.bloodPressure.rawValue:
      return HKUnit.millimetersOfMercury()
    case HKQuantityTypeIdentifier.bodyFatPercentage.rawValue:
      return HKUnit.percent()
    case HKQuantityTypeIdentifier.oxygenSaturation.rawValue:
      return HKUnit.percent()
    case HKQuantityTypeIdentifier.respiratoryRate.rawValue:
      return HKUnit.count().unitDivided(by: .minute())
    case HKQuantityTypeIdentifier.bodyMassIndex.rawValue:
      return HKUnit.count()
    case HKQuantityTypeIdentifier.leanBodyMass.rawValue:
      return HKUnit.gramUnit(with: .kilo)
    case HKQuantityTypeIdentifier.waistCircumference.rawValue:
      return HKUnit.meter()
    case HKQuantityTypeIdentifier.distanceWalkingRunning.rawValue,
      HKQuantityTypeIdentifier.distanceCycling.rawValue,
      HKQuantityTypeIdentifier.distanceSwimming.rawValue:
      return HKUnit.meter()
    case HKQuantityTypeIdentifier.flightsClimbed.rawValue:
      return HKUnit.count()
    case HKQuantityTypeIdentifier.vo2Max.rawValue:
      return HKUnit.literUnit(with: .milli).unitDivided(
        by: HKUnit.gramUnit(with: .kilo).unitMultiplied(by: .minute()))
    case HKQuantityTypeIdentifier.restingHeartRate.rawValue,
      HKQuantityTypeIdentifier.walkingHeartRateAverage.rawValue:
      return HKUnit.count().unitDivided(by: .minute())
    case HKQuantityTypeIdentifier.heartRateVariabilitySDNN.rawValue:
      return HKUnit.secondUnit(with: .milli)
    case HKQuantityTypeIdentifier.electrocardiogram.rawValue:
      return HKUnit.volt()
    case HKQuantityTypeIdentifier.appleExerciseTime.rawValue,
      HKQuantityTypeIdentifier.appleStandTime.rawValue:
      return HKUnit.minute()
    case HKQuantityTypeIdentifier.environmentalAudioExposure.rawValue,
      HKQuantityTypeIdentifier.headphoneAudioExposure.rawValue:
      return HKUnit.decibelAWeightedSoundPressureLevel()
    case HKQuantityTypeIdentifier.waterAmount.rawValue:
      return HKUnit.liter()
    case HKQuantityTypeIdentifier.uvExposure.rawValue:
      return HKUnit.count()
    case HKQuantityTypeIdentifier.mindfulSession.rawValue:
      return HKUnit.minute()
    default:
      return HKUnit.count()  // Default fallback unit
    }
  }
}
