
public class SpeedDebuff
{
	public float rigidityValue = 1f;
	public float skillValue = 1f;
	public float groggyValue = 1f;
	public float slowMoveValue = 1f;

	public void Initialize()
	{
		rigidityValue = 1f;
		skillValue = 1f;
		groggyValue = 1f;
		slowMoveValue = 1f;
	}

	public float GetValue()
	{
		return rigidityValue * skillValue * groggyValue * slowMoveValue;
	}
}