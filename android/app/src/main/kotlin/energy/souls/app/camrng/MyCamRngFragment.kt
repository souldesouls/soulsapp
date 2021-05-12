package energy.souls.app.camrng

import android.Manifest
import android.annotation.TargetApi
import android.content.Context
import android.content.pm.PackageManager
import android.os.*
import android.view.*
import android.widget.Toast
import androidx.core.app.ActivityCompat
import androidx.core.content.ContextCompat
import androidx.fragment.app.Fragment
import io.reactivex.android.schedulers.AndroidSchedulers
import io.reactivex.disposables.CompositeDisposable
import io.reactivex.schedulers.Schedulers
import kotlinx.android.synthetic.main.dialog_camrng.*
import android.view.SurfaceHolder
import android.view.animation.Animation
import android.view.animation.LinearInterpolator
import android.view.animation.RotateAnimation
import androidx.annotation.RequiresApi
import energy.souls.app.R
import energy.souls.app.camrng.NoiseBasedCamRng
import kotlinx.android.synthetic.main.dialog_camrng.view.*
import android.util.Log

class MyCamRngFragment : Fragment(), SurfaceHolder.Callback, Handler.Callback {
    companion object {
        const val REQUEST_PERMISSIONS = 1
        var mCameraSurface: Surface? = null
    }

    lateinit var rootView: View;
    lateinit var SM: SendMessage;
    lateinit var camRng: NoiseBasedCamRng;

    private lateinit var mSurfaceView: SurfaceView;
    private lateinit var mSurfaceHolder: SurfaceHolder;

    private var entropyneeded = 256;
    private var MSG_SURFACE_READY = 2
    private var mSurfaceCreated = true
    private var mHandler = Handler(this)
    private var compositeDisposable = CompositeDisposable()

    //Interface for MainActivity
    interface SendMessage {
        fun sendEntropyObj(size: Int, entropy :String)
    }

    override fun onCreateView(inflater: LayoutInflater, container: ViewGroup?, savedInstanceState: Bundle?): View? {
        rootView = inflater.inflate(R.layout.dialog_camrng, container,false)

        //Set entropy left from entropy given
//        val bundle = this.arguments
//        if (bundle != null) {
//            entropyneeded = bundle.getInt("bytesNeeded", 256)
//        }

//        rootView.entropyLeftTextView.text = entropyneeded.toString();

        return rootView
    }

    override fun onStart() {
        super.onStart()
        setupRngAndViews()
    }

    @TargetApi(Build.VERSION_CODES.LOLLIPOP)
    private fun  setupRngAndViews() {
        mSurfaceView = surfaceViewCAM;
        mSurfaceHolder = mSurfaceView.getHolder();
        mSurfaceHolder.addCallback(this);
    }

    @RequiresApi(Build.VERSION_CODES.LOLLIPOP)
    override fun handleMessage(msg: Message): Boolean {
        if (mSurfaceCreated) {
            try {
                //Set image animation to spin
                val rotate = RotateAnimation(0F, 359F, Animation.RELATIVE_TO_SELF, 0.5f, Animation.RELATIVE_TO_SELF, 0.5f)
                rotate.setRepeatCount(Animation.INFINITE)
                rotate.setDuration(10000)
                rotate.setInterpolator(LinearInterpolator())
                camRNGImage.startAnimation(rotate)

                //Start camRNG instance
                camRng = NoiseBasedCamRng.newInstance(context = requireContext());

                //Set TextView in view
//                entropyLeftTextView.text = entropyneeded.toString()
//                usedPixelsTextView.text = NoiseBasedCamRng.getNumberOfPixelsInUse().toString()

                //Start timer
                timeLapsedCmTimer.start()

                //Store entropy in bytes format
                var bytes = byteArrayOf()

                //Set cancel button
                camRNGCancelButton.setOnClickListener {
                    SM?.sendEntropyObj(0, "Cancel")
                    compositeDisposable.dispose()
                }

                compositeDisposable.add(
                        camRng.getBytes()
                                .subscribeOn(Schedulers.newThread())
                                .observeOn(AndroidSchedulers.mainThread())
                                .subscribe {
                                    bytes += it.toByte()
//                                    bytesInBufferTextView.text = bytes.size.toString()
//                                    entropyGeneratedTextView.text = ((bytes.size) * 2).toString()

                                    // Rough progress until finish entropy generation
                                    val progress = bytes.size.toDouble()/entropyneeded*100
                                    etaRemaining.text = "%.0f".format(progress) + "%"

                                    if(bytes.size >= entropyneeded){
                                        val sb = StringBuilder()
                                        for (b in bytes) {
                                            sb.append(String.format("%02x", b))
                                        }
                                        compositeDisposable.dispose()

                                        //Send message to main activity and launch Soulsfragment
                                        SM?.sendEntropyObj(entropyneeded, sb.toString())
                                    }
                                }
                )
            } catch (t: Throwable) {
                t.printStackTrace()
                Toast.makeText(requireContext(), t.message, Toast.LENGTH_LONG).show()
            }
        }
        return true
    }


    override fun surfaceCreated(holder: SurfaceHolder) {
        mCameraSurface = holder.surface
    }

    override fun surfaceChanged(holder: SurfaceHolder, format: Int, width: Int, height: Int) {
        mCameraSurface = holder.surface
        mSurfaceCreated = true
        mHandler.sendEmptyMessage(MSG_SURFACE_READY)
    }

    override fun surfaceDestroyed(holder: SurfaceHolder) {
        mSurfaceCreated = false
    }

    override fun onAttach(context: Context) {
        super.onAttach(context)
        try {
            SM = (activity as SendMessage?)!!
        } catch (e: ClassCastException) {
            throw ClassCastException("Error in retrieving data. Please try again")
        }
    }
    override fun onPause() {
        super.onPause()
        NoiseBasedCamRng.reset()
    }

    override fun onDestroy() {
        super.onDestroy()
        compositeDisposable.dispose()
    }

}
