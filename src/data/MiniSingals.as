package data
{
	import data.message.ActiveReq;
	import data.message.PauseReq;
	
	import org.osflash.signals.Signal;

	public class MiniSingals
	{
		public static var OnPauseReq:Signal = new Signal(PauseReq);
		public static var OnActiveReq:Signal = new Signal(ActiveReq);
	}
}