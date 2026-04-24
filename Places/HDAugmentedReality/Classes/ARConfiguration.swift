import CoreLocation
import UIKit

let LAT_LON_FACTOR: CGFloat = 1.33975031663                      // Used in azimuzh calculation, don't change
let VERTICAL_SENS: CGFloat = 960
let H_PIXELS_PER_DEGREE: CGFloat = 14                            // How many pixels per degree
let FOV_Y = 0.96
let OVERLAY_VIEW_WIDTH: CGFloat = 360 * H_PIXELS_PER_DEGREE      // 360 degrees x sensitivity

let MAX_VISIBLE_ANNOTATIONS: Int = 500                           // Do not change, can affect performance
let MAX_VERTICAL_LEVELS: Int = 10                                // Do not change, can affect performance

internal func radiansToDegrees(_ radians: Double) -> Double
{
    return (radians) * (180.0 / Double.pi)
}

internal func degreesToRadians(_ degrees: Double) -> Double
{
    return (degrees) * (Double.pi / 180.0)
}

/// Normalizes degree to 360
internal func normalizeDegree(_ degree: Double) -> Double
{
    var degreeNormalized = fmod(degree, 360)
    if degreeNormalized < 0
    {
        degreeNormalized = 360 + degreeNormalized
    }
    return degreeNormalized
}

/// Finds shortes angle distance between two angles. Angles must be normalized(0-360)
internal func deltaAngle(_ angle1: Double, angle2: Double) -> Double
{
    var deltaAngle = angle1 - angle2
    
    if deltaAngle > 180
    {
        deltaAngle -= 360
    }
    else if deltaAngle < -180
    {
        deltaAngle += 360
    }
    return deltaAngle
}




